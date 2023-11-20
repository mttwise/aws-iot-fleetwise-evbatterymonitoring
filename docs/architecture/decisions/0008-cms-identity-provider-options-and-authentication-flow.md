# 8. CMS Identity Provider Options and Authentication Flow

Date: 2023-06-19

## Status

Accepted

## Context

Connected Mobility Solution (CMS) needs a way to authenticate users throughout the entire solution.

Authentication is a required aspect of using CMS, and therefore customers should be asked to use a CMS provided IdP option, or swap out the default IdP for an IdP of their
choosing which supports OAuth2.0. Supporting a third-party IdP requires conditionally performing operations such as redirecting to the IdPs authentication UI
and validating the returned JSON Web Token (JWT). These conditionals would be determined by IdP configuration details provided by the customer.

Once authenticated via the IdP, provided tokens (authorization code or some combination of identity token, access token, and/or refresh token) need to be
validated via a generalized method that will work with any IdP. The token should then be parsed and associated with a CMS created unique user record
that we can use for future features such as user authorization and user-vehicle mapping.

Once authenticated, the customer should be allowed to specify whether a user should retain access to CMS throughout their session, or whether authentication expiration is preferred.

Requirements:
- Any CMS module can use a solution wide, shared authentication flow
- Provide a default identity provider (IdP) option for authentication which is shared throughout the entire solution
- Allow swapping the default IdP with any other IdP that supports OAuth 2.0
- Enable association between an authenticated user and a CMS user record which is compatible with all applicable IdPs
- Gracefully handle token expiration based on customer preference

## Decisions

The existence of a CMS authentication IdP and lambda function, as well valid SSM parameters defining their configuration, are a pre-requisite of the CMS Instance deployment

CMS will use Cognito User Pool as our default IdP for authentication. The user pool will use the authorization code OAuth 2.0 flow,
which prevents the access token from being exposed to the client. We will utilize the Cognito hosted-ui for interfacing with the user pool and
retrieving the authorization code.

If swapping the CMS provided IdP with an alternative, the customer must provide their own hosted domain to interface with the IdP and retrieve tokens. CMS will not
provide a custom user interface (UI) for interfacing with third-party IdPs or retrieving third-party IdP tokens.

IdP configuration parameters will be asked of the customer and referenced by other modules via SSM as necessary for deployment and runtime
functionality. These parameters would enable functionality such as redirecting to the IdPs UI, defining scope, and accessing necessary user claims.

CMS will use a custom lambda to validate IdP authentication tokens. All API options currently being considered for CMS support a custom lambda auth option
to invoke the lambda on an API call. The custom authentication lambda will validate the returned JWT, referencing IdP configuration parameters provided by
the customer if necessary. By implementing a custom OAuth 2.0 compliant validator, CMS will support using any OAuth2.0 compliant IdP and be fully decoupled from Cognito.

As part of the authentication lambda, a user profile retrieval will be attempted from a CMS internal database. This retrieval is handled by a "user profile lambda" which is not
part of the authentication module, but is rather just invoked by the authentication lambda if a valid SSM reference to the "user profile lambda" is found. Details of the "user
profile lambda" are outside the scope of this ADR and the authentication module.

The customer will specify whether tokens should be refreshed or expired as part of the IdP configuration parameters. The CMS default IdP will use the authorization code OAuth2.0 flow,
which guarantees a refresh token which can be used to refresh the users access token when necessary without interupting the user experience. For third-party IdPs, we should not require a
specific OAuth2.0 flow. If the third-party IdP also uses the authorization code flow, the same refresh method can be used. If a different flow is used, a refresh token is not
guaranteed, and the user will have to reauthenticate with the IdP upon expiration of their access token. If a customer requests token refresh instead of expiration, the IdP option
chosen must use an OAuth2.0 flow which provides a refresh token.

## Consequences

This decision solidifies authentication as a requirement for deploying CMS. However, CMS will support customers using any OAuth2.0 compliant third-party IdP, while also
providing a default IdP option. By supporting alternative IdP options, CMS does add a customer requirement of providing a UI for interfacing with the IdP.

Existing CMS modules  (Vehicle Simulator, Portal, and CMS Instance) currently implement an authentication flow which will require refactoring to utilize this new, shared
OAuth2.0 authentication flow provided by the authentication module.

The CMS authentication module is mostly decoupled from the user profile schema, retrieval, and creation process, but will require a dependency contract between the authentication
lambda and the "user profile lambda".

By implementing a JWT validation lambda, we keep CMS open to implementing future authorization which is independent of IdP choice and fully decoupled from Cognito.

This system can be developed incrementally without requiring significant refactoring throughout the development process.
