import { useCallback } from "react";

export default function useGetUser() {
    return useCallback(async () => {
        const response = await fetch("http://localhost:8080/user", {
            method: "GET",
            credentials: "include"
        });

        if (!response.ok)
            throw new Error("Failed to fetch user");

        return await response.json();
    }, []);
}
