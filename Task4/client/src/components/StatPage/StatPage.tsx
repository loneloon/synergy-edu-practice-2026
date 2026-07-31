import React, { ReactElement, useCallback, useEffect, useState } from "react";
import style from './StatPage.less'
import { CircularTracker } from "../StatPage/CircularTracker/CircularTracker";
import { CompletedActivity } from "../TrackerPage/ActivityTracker/ActivityTracker";


interface StatPageProps {
    sectionsRef: any;
    activityColors: Record<string, string>;
    activityHistory: CompletedActivity[];
}


export function StatPage({sectionsRef, activityColors, activityHistory}: StatPageProps): ReactElement {
    return (
        <div
            ref={(element) => {
                sectionsRef.current[2] = element;
            }}
            className={style.statPage}
            id="section3"
        >
            <CircularTracker
                activityHistory={activityHistory}
                activityColors={activityColors}
                size={700}
                thickness={28}
                gap={0.5}
            />
        </div>
    )
}
