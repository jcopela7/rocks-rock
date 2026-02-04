import { useAuth0 } from "@auth0/auth0-react";
import { Button } from "@geist-ui/core";

export function LogoutButton() {
  const { logout } = useAuth0();

  return (
    /* @ts-expect-error Geist Button typing is overly strict */
    <Button type="secondary" onClick={() => logout({ logoutParams: { returnTo: window.location.origin } })}>
      Log Out
    </Button>
  );
}
