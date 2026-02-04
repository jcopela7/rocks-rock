import { useAuth0 } from "@auth0/auth0-react";
import { CssBaseline, GeistProvider, Spacer, Text } from "@geist-ui/core";
import "./App.css";
import { AuthTokenBridge } from "./auth/AuthTokenBridge";
import { LoginButton } from "./auth/LoginButton";
import { LogoutButton } from "./auth/LogoutButton";
import LocationsTable from "./components/LocationsTable";
import RoutesTable from "./components/RoutesTable";

function App() {
  const { isAuthenticated, isLoading } = useAuth0();

  if (isLoading) {
    return (
      <GeistProvider>
        <CssBaseline />
        <div className="App" style={{ padding: "20px" }}>
          <Text p>Loading…</Text>
        </div>
      </GeistProvider>
    );
  }

  if (!isAuthenticated) {
    return (
      <GeistProvider>
        <CssBaseline />
        <div className="App" style={{ padding: "20px", textAlign: "center" }}>
          <Text h1>Admin Portal</Text>
          <Text p>Log in to manage climbing locations and routes</Text>
          <Spacer h={2} />
          <LoginButton />
        </div>
      </GeistProvider>
    );
  }

  return (
    <GeistProvider>
      <CssBaseline />
      <AuthTokenBridge />
      <div className="App" style={{ padding: "20px" }}>
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
          }}
        >
          <div>
            <Text h1>Admin Portal</Text>
            <Text p>Manage your climbing locations and routes</Text>
          </div>
          <LogoutButton />
        </div>
        <Spacer h={2} />
        <LocationsTable />
        <Spacer h={1.5} />
        <RoutesTable />
      </div>
    </GeistProvider>
  );
}

export default App;
