# 9. CMS User and Vehicle Authorization

Date: 2023-06-19

## Status

Pending Approval

## Context

CMS must support fine grained access control which is dependent on an authenticated user identity. Our fine grained access control standard should enable users
to be granted permissions both individually, and in groups. Similar, users should be associated to vehicle both individually and in groups (fleets). The configuration
of these permissions should include both defaults provided by CMS, as well as being customizable by the customer.

The CMS authentication implementation allows a customer to authenticate their users using any OAuth2.0 compliant third-party IdP. This means that our authorization
method has to be decoupled from the default CMS IdP option and provide configuration options that allow compatability with various third-party IdPs.

AWS offers two primary options for authorization through Cognito. Cognito user pools, which are being used as CMS's default IdP, can also
act as an authorizer by specifying cognito groups and scope that can be checked by an API authorizor. However, we can not rely on Cognito user pools since
CMS supports third party IdPs. Cognito identity pools can also be used to provide authorization in the form of IAM permissions. However, the Cognito
identity pool implementation is tightly coupled with Cognito user pools, and there has been sentiment expressed by the business to avoid
requiring Cognito in any capacity.

The CMS authentication system promises to provide an access token as the physical representation of an authenticated user, assuming an authenticated
user was found in the customer's IdP. Our authorization method can rely on the existence of this token, but specific claims within the token are not
a guarantee. Because of this, parsing of the access token will be dependent on the IdP configuration parameters provided by the customer.

Requirements:
1. Permissions can be granted to users both individually, and in groups
2. Vehicle ownership can be granted to user both individually, and via fleets (group of vehicles)
3. CMS provides pre-configured options for permissions and permission groups, as well as allowing customers to manage and customize these options themselves
4. Authorization needs to support any OAuth2.0 compliant third-party IdP (IdP)

## Decision

CMS will implement a custom authorization system using database tables for permission storage, rather than using a pre-built authorization option.
The authorization check will be handled via a custom lambda function attached to the CMS APIs. The following data requirements allow CMS to satisfy
all of the above requirements:
- Permissions:
  - A pre-defined list of CMS permissions.
  - A pre-defined list of CMS permission groups with associated permissions. This should be customizable by the customer.
  - A pre-defined mapping of API endpoints to their required permission, as well as whether the API endpoint requires a vehicle ownership check.
- Vehicles and Fleets:
  - A many-to-many association model for users to vehicles.
  - A many-to-many association model for users to fleets.
  - A many-to-many association model for fleets to vehicles.
- User profiles initial setup:
  - User profile creation, triggered by the authentication lambda not finding an existing profile, will handle initial user permission and permission group setup via access token claims. The keys of which can be defined via the IdP configuration.
  - Vehicles will be mapped to a default fleet (with a default fleet owner) during the provisoning process via a provisioning template parameter
- Permissions management:
  - CMS will provide a permissions management system for managing user permissions and permission groups
  - CMS will provide a permissions management system for creating and customizing permission groups
- Vehicle and fleet management:
  - CMS will provide a vehicle and fleet management system for managing a user's vehicle and fleet associations
  - CMS will provide a vehicle and fleet management system for creating and customizing fleets

## Consequences

As a result of this decision, CMS will support fine grained access control based on an authenticated user identity. Access control is determined by associating users
with a combination of pre-configured and user customized permission groups, which group together pre-defined CMS permissions, as well as individual CMS permissions.
In a similar way, users can be associated with customizable groups of, and individual, vehicles. Providing pre-configured authorization options adds extra responsibility to the
development team for maintaining these defaults and their documentation.

A custom authorization system will likely require a management system for users, permission groups, vehicles, and fleets. The details of these management systems are unknown,
and determining them now is unnecessary since they are outside of our current release scope. This is a risk in regards to unknown future development effort, however, it does
leave the CMS solution open to a wide variety of management strategies. A custom authorization system does also allow CMS authorization to support any OAuth2.0 compliant third-party
IdP, and be decoupled from our API implementations.
