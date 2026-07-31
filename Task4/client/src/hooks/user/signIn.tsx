import { useCallback } from "react";
import getStringHash from "./hash";

export default function useSignIn() {
    return useCallback(async (username: string, password: string) => {
        const secret: string = await getStringHash(password);

        const response = await fetch("http://localhost:8080/user/sign-in", {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                username,
                secret,
            }),
        });

        if (!response.ok)
            throw new Error("Sign in failed");

        return await response.json();
    }, []);
}
