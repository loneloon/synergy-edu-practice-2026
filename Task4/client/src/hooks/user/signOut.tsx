import { useCallback } from "react";

export default function useSignOut() {
    return useCallback(async () => {
        const response = await fetch("http://localhost:8080/user/sign-out", {
            method: "GET",
            credentials: "include"
        });

        if (!response.ok)
            throw new Error("Sign out failed");
    }, []);
}
