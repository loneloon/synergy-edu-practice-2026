import React, { ReactElement, useCallback, useEffect, useState } from "react";
import style from './TrackerPage.less'
import { ActivityTracker, CompletedActivity } from "./ActivityTracker/ActivityTracker";


interface TrackerPageProps {
    sectionsRef: any;
    activityTypes: string[];
    activityColors: Record<string, string>;
    setActivityHistoryFn: any;
    activityHistory: CompletedActivity[];
}


export function TrackerPage({sectionsRef, activityTypes, activityColors, setActivityHistoryFn, activityHistory}: TrackerPageProps): ReactElement {
    return (
        <div
            ref={(element) => {
                sectionsRef.current[1] = element;
            }}
            className={style.trackerPage}
            id="section2"
        >
            <ActivityTracker activityTypes={activityTypes} activityColors={activityColors} setActivityHistoryFn={setActivityHistoryFn} activityHistory={activityHistory}/>
        </div>
    )
}
