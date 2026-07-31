import { useCallback } from "react";

export default function useFinishActivity() {
    return useCallback(
        async (
            activity_name: string,
            group_name: string
        ) => {
            const response = await fetch("http://localhost:8080/activity/finish", {
                method: "POST",
                credentials: "include",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    activity_name,
                    group_name
                }),
            });

            if (!response.ok)
                throw new Error("Activity finish failed");

            return await response.json();
        },
        []
    );
}
