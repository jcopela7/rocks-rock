import { CssBaseline, GeistProvider, Spacer, Text } from "@geist-ui/core";
import "./App.css";
import LocationsTable from "./components/LocationsTable";

function App() {
  return (
    <GeistProvider>
      <CssBaseline />
      <div className="App" style={{ padding: "20px" }}>
        <Text h1>Admin Portal</Text>
        <Text p>Manage your climbing locations and routes</Text>
        <Spacer h={2} />
        <LocationsTable />
      </div>
    </GeistProvider>
  );
}

export default App;
