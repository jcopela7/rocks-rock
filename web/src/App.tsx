import { Card, CssBaseline, GeistProvider, Spacer, Table, Text } from '@geist-ui/core';
import './App.css';

function App() {
  // Sample data - replace with real data from your API later
  const locations = [
    { id: 1, name: 'Yosemite Valley', description: 'Classic granite climbing', difficulty: '5.6-5.14' },
    { id: 2, name: 'Red River Gorge', description: 'Sandstone sport climbing', difficulty: '5.8-5.14' },
    { id: 3, name: 'Joshua Tree', description: 'Desert bouldering and trad', difficulty: 'V0-V12' },
  ];

  return (
    <GeistProvider>
      <CssBaseline />
      <div className="App" style={{ padding: '20px' }}>
        <Text h1>Admin Portal</Text>
        <Text p>Manage your climbing locations and routes</Text>
        
        <Spacer h={2} />
        
        <Card>
          <Text h3>Locations</Text>
          <Table data={locations}>
            <Table.Column prop="name" label="Name" />
            <Table.Column prop="description" label="Description" />
            <Table.Column prop="difficulty" label="Difficulty Range" />
          </Table>
        </Card>
      </div>
    </GeistProvider>
  );
}

export default App;