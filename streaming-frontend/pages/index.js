import { useState, useEffect } from 'react';

const initItems = [
  {
    id: 1,
    name: 'Protocol 1',
    description: 'Description of protocol 1',
  },
  {
    id: 2,
    name: 'Protocol 2',
    description: 'Description of protocol 2',
  },
];

export default function Home() {
  const [items, setItems] = useState(initItems);
  useEffect(() => {
    const socket = new WebSocket('wss://echo.websocket.org');
    socket.onmessage = (event) => {
      setItems((items) => [...items, event.data]);
    };
  }, []);

  return (
    <div className="m-4 rounded-lg bg-blue-400 p-4">
      <h1 className="">Newest protocols</h1>
      <div className="border-2 border-blue-800 m-2"></div>
      <div>
        {items.map((item) => (
          <div key={item.id}>{JSON.stringify(item)}</div>
        ))}
      </div>
    </div>
  );
}
