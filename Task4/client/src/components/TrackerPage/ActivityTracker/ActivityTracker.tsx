import { ReactElement, useCallback, useEffect, useState } from "react";
import styles from "./ActivityTracker.less";
import React from "react";
import useStartActivity from "../../../hooks/activity/startActivity";
import useFinishActivity from "../../../hooks/activity/finishActivity";
import useGetActivityHistory from "../../../hooks/activity/getHistory";
import { DateTime } from 'luxon';


export interface CompletedActivity {
    name: string;
    category: string;
    startedAt: number|null;
    endedAt: number|null;
}

function twoDigits(value: number): string {
    return (value < 10 ? "0" : "") + value;
}

function formatElapsedTime(startTimestamp: number): string {
    const elapsedMilliseconds = Math.max(0, Date.now() - startTimestamp);
    const totalSeconds = Math.floor(elapsedMilliseconds / 1000);

    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    return [
        twoDigits(hours),
        twoDigits(minutes),
        twoDigits(seconds),
    ].join(":");
}

function formatClockTime(timestamp: number): string {
    const date = new Date(timestamp);

    return [
        twoDigits(date.getHours()),
        twoDigits(date.getMinutes()),
    ].join(":");
}

function formatActivityLength(
    startedAt: number,
    endedAt: number
): string {
    const totalMinutes = Math.floor(
        (endedAt - startedAt) / 1000 / 60
    );

    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;

    if (hours === 0) {
        return `${minutes} min`;
    }

    return `${hours} hr ${minutes} min`;
}


interface ActivityTrackerProps {
    activityTypes: string[];
    activityColors: Record<string, string>;
    setActivityHistoryFn: any;
    activityHistory: CompletedActivity[];
}


export function ActivityTracker({activityTypes, activityColors, setActivityHistoryFn, activityHistory}: ActivityTrackerProps): ReactElement {
    const [currentActivityName, setCurrentActivityName] =
        useState<string|null>(null);

    const [currentActivityCategory, setCurrentActivityCategory] =
        useState<string|null>(null);

    // Timestamp from which the stopwatch counts.
    const [activityStartedAt, setActivityStartedAt] = useState<number>(
        Date.now()
    );

    const [elapsedTime, setElapsedTime] = useState("00:00:00");
    const [isActivityRunning, setIsActivityRunning] = useState(false);

    const [nextActivityName, setNextActivityName] = useState("");
    const [nextActivityCategory, setNextActivityCategory] = useState(
        activityTypes[0]
    );

    const startActivityRequest = useStartActivity();
    const finishActivityRequest = useFinishActivity();
    const getActivityHistory = useGetActivityHistory();

    const getHistory = useCallback(async () => {
            const activityHistory = await getActivityHistory();
            if (activityHistory) {
                let latestUnfinished: any = null;
                const remapped = activityHistory.map((record: any) => {
                    const activityName = record.name;
                    const groupName = record.group;
                    const startedAt = record.startTs ? DateTime.fromFormat(record.startTs, "M/d/yyyy h:mm:ss a") : null;
                    const endedAt = record.endTs ? DateTime.fromFormat(record.endTs, "M/d/yyyy h:mm:ss a") : null;
                    
                    const activity: CompletedActivity = {
                        name: activityName,
                        category: groupName,
                        startedAt: startedAt ? startedAt.toMillis() : null,
                        endedAt: endedAt ? endedAt.toMillis() : null
                    };
                    if (startedAt && !endedAt) {
                        latestUnfinished = {
                            name: activityName,
                            category: groupName,
                            startedAt: startedAt
                        };
                    }
                    if (!endedAt) {
                        return null;
                    }
                    return activity;
                    
                }).filter((el: any) => el);
                setActivityHistoryFn(remapped);
                
                if (latestUnfinished && latestUnfinished.startedAt) {
                    setIsActivityRunning(true);
                    setCurrentActivityName(latestUnfinished.name);
                    setCurrentActivityCategory(latestUnfinished.category);
                    setActivityStartedAt(latestUnfinished.startedAt.toMillis());
                    setElapsedTime(DateTime.now().diff(latestUnfinished.startedAt).toFormat("hh:mm:ss"));
                }
            }
        }, []);

    useEffect(() => {
        getHistory();

        if (!isActivityRunning) {
            return;
        }

        const updateStopwatch = (): void => {
            setElapsedTime(formatElapsedTime(activityStartedAt));
        };

        updateStopwatch();

        const intervalId = window.setInterval(updateStopwatch, 1000);

        return () => {
            window.clearInterval(intervalId);
        };
    }, [activityStartedAt, isActivityRunning]);
    
    const finishActivity = async () => {
        if (isActivityRunning && currentActivityName && currentActivityCategory) {
            try {
                await finishActivityRequest(currentActivityName, currentActivityCategory);
                setIsActivityRunning(false);
                setElapsedTime("00:00:00");
            } catch (err) {
                console.error(err);
            }
        }
    };

    const startNextActivity = async () => {
        await finishActivity();

        const trimmedName = nextActivityName.trim();
        const activityName: string = trimmedName.length > 0 ? trimmedName : nextActivityCategory;

        try {
                await startActivityRequest(activityName, nextActivityCategory);
                setCurrentActivityName(activityName);
                setCurrentActivityCategory(nextActivityCategory);
                setActivityStartedAt(Date.now());
                setElapsedTime("00:00:00");
                setIsActivityRunning(true);
                setNextActivityName("");
            } catch (err) {
                console.error(err);
            }
    };

    return (
        <section className={styles.activityTracker}>
            <div className={styles.currentActivityBar}>
                <div className={styles.activityIdentity}>
                    <span className={styles.label}>
                        Current activity:
                    </span>

                    <span className={styles.activityName}>
                        {isActivityRunning
                            ? currentActivityName
                            : "Idle"}
                    </span>

                    {isActivityRunning && (
                        <span className={styles.category}>
                            {currentActivityCategory}
                        </span>
                    )}
                </div>

                <time className={styles.stopwatch}>
                    {elapsedTime}
                </time>

                <div
                    className={`${styles.button} ${
                        styles.finishButton
                    } ${
                        !isActivityRunning
                            ? styles.disabledButton
                            : ""
                    }`}
                    role="button"
                    tabIndex={isActivityRunning ? 0 : -1}
                    onClick={finishActivity}
                    onKeyDown={(event) => {
                        if (
                            isActivityRunning &&
                            (event.key === "Enter" ||
                                event.key === " ")
                        ) {
                            event.preventDefault();
                            finishActivity();
                        }
                    }}
                >
                    Finish
                </div>
            </div>

            {activityHistory.length > 0 && (
                <div className={styles.completedActivitiesList}>
                    {activityHistory.map((activity, index) => (
                        <div
                            className={styles.completedActivityBar}
                            key={`${activity.startedAt}-${index}`}
                        >
                            <div className={styles.activityIdentity}>
                                <span className={styles.activityName}>
                                    {activity.name}
                                </span>

                                <span style={{"background": activityColors[activity.category], "color": "#fafafa"}} className={styles.category}>
                                    {activity.category}
                                </span>
                            </div>

                            <div className={styles.activityTimeRange}>
                                <span>
                                    {formatClockTime(activity.startedAt)}
                                </span>

                                <span className={styles.timeSeparator}>
                                    –
                                </span>

                                <span>
                                    {formatClockTime(activity.endedAt)}
                                </span>
                            </div>

                            <span className={styles.activityLength}>
                                {formatActivityLength(
                                    activity.startedAt,
                                    activity.endedAt
                                )}
                            </span>
                        </div>
                    ))}
                </div>
            )}

            <div className={styles.nextActivitySection}>
                <label
                    className={styles.sectionLabel}
                    htmlFor="next-activity-name"
                >
                    Choose next activity
                </label>

                <div className={styles.controls}>
                    <input
                        id="next-activity-name"
                        className={styles.activityInput}
                        type="text"
                        value={nextActivityName}
                        placeholder="Activity name"
                        onChange={(event) =>
                            setNextActivityName(event.target.value)
                        }
                        onKeyDown={(event) => {
                            if (event.key === "Enter") {
                                startNextActivity();
                            }
                        }}
                    />

                    <select
                        className={styles.activitySelect}
                        value={nextActivityCategory}
                        onChange={(event) =>
                            setNextActivityCategory(event.target.value)
                        }
                    >
                        {activityTypes.map((activityType) => (
                            <option
                                key={activityType}
                                value={activityType}
                            >
                                {activityType}
                            </option>
                        ))}
                    </select>

                    <div
                        className={`${styles.button} ${styles.startButton}`}
                        role="button"
                        tabIndex={0}
                        onClick={startNextActivity}
                        onKeyDown={(event) => {
                            if (
                                event.key === "Enter" ||
                                event.key === " "
                            ) {
                                event.preventDefault();
                                startNextActivity();
                            }
                        }}
                    >
                        Start
                    </div>
                </div>
            </div>
        </section>
    );
}
