import { CssBaseline, GeistProvider, Spacer, Text } from "@geist-ui/core";
import "./App.css";
import LocationsTable from "./components/LocationsTable";
import RoutesTable from "./components/RoutesTable";

function App() {
  return (
    <GeistProvider>
      <CssBaseline />
      <div className="App" style={{ padding: "20px" }}>
        <Text h1>Admin Portal</Text>
        <Text p>Manage your climbing locations and routes</Text>
        <Spacer h={2} />
        <LocationsTable />
        <Spacer h={1.5} />
        <RoutesTable />
      </div>
    </GeistProvider>
  );
}

export default App;
