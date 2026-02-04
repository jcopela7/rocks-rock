import { useEffect } from "react";
import { useAuth0 } from "@auth0/auth0-react";
import { setTokenGetter } from "../api/client";

/**
 * Bridges Auth0's getAccessTokenSilently to the API client.
 * Renders nothing; must be mounted inside Auth0Provider.
 */
export function AuthTokenBridge() {
  const { isAuthenticated, getAccessTokenSilently } = useAuth0();

  useEffect(() => {
    if (isAuthenticated) {
      setTokenGetter(() => getAccessTokenSilently());
    } else {
      setTokenGetter(null);
    }
    return () => setTokenGetter(null);
  }, [isAuthenticated, getAccessTokenSilently]);

  return null;
}
