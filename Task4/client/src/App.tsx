import * as React from 'react';
import { ReactElement, useCallback, useEffect, useRef, useState } from 'react';
import { UserPage } from './components/UserPage/UserPage';
import { AppContent } from './components/AppContent/AppContent';


interface UserActivity {
    "name": string;
    "group": string;
    "start": number;
    "end": number|null;
}

interface User {
    username: string;
    history: Record<string, UserActivity[]>|null;
}


function App(): ReactElement {
    const [user, setUser] =  useState<User|null>(null);

    useEffect(() => {
        if (user && user.username) {
            console.log("get history here");
        }
    }, [user])

    return user ? (<AppContent setUserFn={setUser}/>) : (<UserPage setUserFn={setUser}/>);
}

export default App;
