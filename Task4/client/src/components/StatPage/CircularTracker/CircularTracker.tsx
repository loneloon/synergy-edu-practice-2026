import React, {
    ReactElement,
    useMemo,
    useState
} from "react";

import styles from "./CircularTracker.less";
import { CompletedActivity } from "../../TrackerPage/ActivityTracker/ActivityTracker";

interface CircularTrackerProps {
    activityColors: Record<string, string>;
    size?: number;
    thickness?: number;
    gap?: number;
    backgroundColor?: string;
    startAngle?: number;
    activityHistory: CompletedActivity[];
}

interface CalculatedSector extends CompletedActivity {
    dashLength: number;
    dashOffset: number;
    percentage: number;
}

function calcActivityLengthInSec(activity: CompletedActivity) {
    if (activity.endedAt && activity.startedAt) {
        return activity.endedAt - activity.startedAt;
    }
    return 0;
}

export function CircularTracker({
    size = 260,
    thickness = 24,
    gap = 0.75,
    backgroundColor = "#25252a",
    startAngle = -90,
    activityColors,
    activityHistory
}: CircularTrackerProps): ReactElement {
    const [hoveredSector, setHoveredSector] =
        useState<CalculatedSector | null>(null);

    const radius = (size - thickness) / 2;
    const circumference = 2 * Math.PI * radius;

    const sectors = useMemo<CalculatedSector[]>(() => {
        const validData = activityHistory.filter(
            (item) => calcActivityLengthInSec(item) > 0
        );

        const totalLength = validData.reduce(
            (sum, item) => sum + calcActivityLengthInSec(item),
            0
        );

        if (totalLength === 0) {
            return [];
        }

        let currentOffset = 0;

        return validData.map((item) => {
            const percentage = calcActivityLengthInSec(item) / totalLength;
            const fullDashLength =
                circumference * percentage;

            const visibleDashLength = Math.max(
                0,
                fullDashLength - gap
            );

            const sector: CalculatedSector = {
                ...item,
                percentage,
                dashLength: visibleDashLength,
                dashOffset: -currentOffset
            };

            currentOffset += fullDashLength;

            return sector;
        });
    }, [activityHistory, circumference, gap]);

    const centerPercentage = hoveredSector
        ? `${(hoveredSector.percentage * 100).toFixed(1)}%`
        : "100%";

    const centerLabel = hoveredSector
        ? hoveredSector.category
        : "Daily activity";

    return (
        <div
            className={styles.tracker}
            style={{
                width: size,
                height: size
            }}
        >
            <svg
                className={styles.svg}
                width={size}
                height={size}
                viewBox={`0 0 ${size} ${size}`}
                role="img"
                aria-label="Circular activity tracker"
                onMouseLeave={() => setHoveredSector(null)}
            >
                <circle
                    cx={size / 2}
                    cy={size / 2}
                    r={radius}
                    fill="none"
                    stroke={backgroundColor}
                    strokeWidth={thickness}
                />

                <g
                    transform={`
                        rotate(
                            ${startAngle}
                            ${size / 2}
                            ${size / 2}
                        )
                    `}
                >
                    {sectors.map((sector, index) => {
                        const isHovered =
                            hoveredSector === sector;

                        return (
                            <circle
                                key={`${sector.category}-${index}`}
                                className={styles.sector}
                                cx={size / 2}
                                cy={size / 2}
                                r={radius}
                                fill="none"
                                stroke={activityColors[sector.category]}
                                strokeWidth={
                                    isHovered
                                        ? thickness + 4
                                        : thickness
                                }
                                strokeLinecap="butt"
                                strokeDasharray={`
                                    ${sector.dashLength}
                                    ${
                                        circumference -
                                        sector.dashLength
                                    }
                                `}
                                strokeDashoffset={
                                    sector.dashOffset
                                }
                                onMouseEnter={() =>
                                    setHoveredSector(sector)
                                }
                                onFocus={() =>
                                    setHoveredSector(sector)
                                }
                                onBlur={() =>
                                    setHoveredSector(null)
                                }
                                tabIndex={0}
                            >
                                <title>
                                    {sector.category}:{" "}
                                    {(
                                        sector.percentage * 100
                                    ).toFixed(1)}
                                    %
                                </title>
                            </circle>
                        );
                    })}
                </g>
            </svg>

            <div
                className={styles.center}
                aria-live="polite"
            >
                <span className={styles.value}>
                    {centerPercentage}
                </span>

                <span className={styles.label}>
                    {centerLabel}
                </span>
            </div>
        </div>
    );
}
