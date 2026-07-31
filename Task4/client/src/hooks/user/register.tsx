import { useCallback } from "react";
import getStringHash from "./hash";

export default function useRegister() {
    return useCallback(
        async (
            username: string,
            email: string,
            password: string
        ) => {
            const secret: string = await getStringHash(password);

            const response = await fetch("http://localhost:8080/user", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    username,
                    email,
                    secret,
                }),
            });

            if (!response.ok)
                throw new Error("Registration failed");

            return await response.json();
        },
        []
    );
}
