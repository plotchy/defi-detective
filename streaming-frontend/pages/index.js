import { useState, useEffect } from 'react';

const initItems = [];
const address = 'ws://10.0.0.91:9002';

export default function Home() {
  const [items, setItems] = useState(initItems);
  useEffect(() => {
    console.log('trying to connect to websocket');
    const socket = new WebSocket(address);
    socket.onopen = () => {
      console.log('connected to websocket');
    };
    socket.onmessage = (event) => {
      console.log('event', event);
      setItems((items) => [...items, JSON.parse(event.data)]);
    };
    return () => {
      socket.close();
    };
  }, []);

  return (
    <div className="m-4 rounded-lg bg-blue-400 p-4">
      <h1 className="">Newest protocols</h1>
      <div className="border-2 border-blue-800 m-2"></div>
      <div className="flex flex-col-reverse">
        {items.map((item, i) => (
          <div key={i} className="bg-gray-300 rounded-lg shadow-lg my-3 p-3">
            New <a href="">{item.network}</a> contract: {item.address}
            <br />
            Deployed by {item.address_from} in block {item.block_number}
            {item.functions.length > 0 && (
              <h4 className="font-bold">Functions:</h4>
            )}
            <ul>
              {item.functions.map((f, j) => (
                <li key={j}>{f}</li>
              ))}
            </ul>
            {item.events.length > 0 && <h4 className="font-bold">Events:</h4>}
            <ul>
              {item.events.map((e, j) => (
                <li key={j}>{e}</li>
              ))}
            </ul>
            {item.most_similar_contracts &&
              item.most_similar_contracts.length > 0 && (
                <>
                  <h4 className="font-bold">Similar protocols:</h4>
                  {item.most_similar_contracts.map((c, j) => (
                    <a key={j} className="m-2">
                      {c}
                    </a>
                  ))}
                </>
              )}
          </div>
        ))}
      </div>
    </div>
  );
}
