import { useCallback } from "react";

export default function useGetActivityHistory() {
    return useCallback(async () => {
        const response = await fetch("http://localhost:8080/activity/history", {
            method: "GET",
            credentials: "include"
        });

        if (!response.ok)
            throw new Error("Failed to fetch activity history");

        return await response.json();
    }, []);
}
