import { useAuth0 } from "@auth0/auth0-react";
import { Button } from "@geist-ui/core";

export function LoginButton() {
  const { loginWithRedirect } = useAuth0();

  return (
    /* @ts-expect-error Geist Button typing is overly strict */
    <Button type="success" onClick={() => loginWithRedirect()}>
      Log In
    </Button>
  );
}
