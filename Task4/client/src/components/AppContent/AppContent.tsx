import React, { ReactElement, useCallback, useEffect, useRef, useState } from "react";
import { InfoPage } from "../InfoPage/InfoPage";
import { TrackerPage } from "../TrackerPage/TrackerPage";
import { StatPage } from "../StatPage/StatPage";
import style from '../../assets/style/base.less'
import useSignOut from "../../hooks/user/signOut";
import { CompletedActivity } from "../TrackerPage/ActivityTracker/ActivityTracker";


const SECTION_COUNT = 3;
const SCROLL_LOCK_MS = 800;
const SWIPE_THRESHOLD = 50;

const activityTypes = [
    "Work",
    "Rest",
    "Social",
    "Family",
    "Exercise",
    "Learning",
    "Hobbies",
    "Food",
    "Hygiene",
    "Entertainment",
    "Housework",
    "Transit/Commute",
    "Outdoors",
    "Other",
];

const activityColors = {
    "Work": "#3B82F6",
    "Rest": "#6366F1",
    "Social": "#EC4899",
    "Family": "#F97316",
    "Exercise": "#22C55E",
    "Learning": "#06B6D4",
    "Hobbies": "#A855F7",
    "Food": "#EAB308",
    "Hygiene": "#14B8A6",
    "Entertainment": "#EF4444",
    "Housework": "#84CC16",
    "Transit/Commute": "#6B7280",
    "Outdoors": "#10B981",
    "Other": "#9CA3AF"
} as Record<string, string>


interface AppContentProps {
    setUserFn: any;
}


export function AppContent({setUserFn}: AppContentProps): ReactElement {
    const sectionsRef = useRef<Array<HTMLDivElement | null>>([]);
    const isScrollingRef = useRef(false);
    const touchStartYRef = useRef(0);

    const [current, setCurrent] = useState(0);
    const [topBarText, setTopBarText] = useState("Info");

    const [completedActivities, setCompletedActivities] = useState<CompletedActivity[]>([]);

    const scrollToSection = useCallback((index: number): void => {
        if (index < 0 || index >= sectionsRef.current.length) {
            return;
        }

        const section = sectionsRef.current[index];

        if (!section || isScrollingRef.current) {
            return;
        }

        isScrollingRef.current = true;

        section.scrollIntoView({
            behavior: "smooth",
            block: "start",
        });

        setCurrent(index);
        switch (index) {
            case 0:
                setTopBarText("Info");
                break;
            case 1:
                setTopBarText("Activity Tracker");
                break;
            case 2:
                setTopBarText("Your Stats Today");
                break;
            default:
                setTopBarText("DailyStat");
                break;
        }

        window.setTimeout(() => {
            isScrollingRef.current = false;
        }, SCROLL_LOCK_MS);
    }, []);

    const signOutRequest = useSignOut();
    const signOut = useCallback(async () => {
            await signOutRequest();
            setUserFn(null);
        }, [signOutRequest]);

    useEffect(() => {
        const handleWheel = (event: WheelEvent): void => {
            if (isScrollingRef.current) {
                return;
            }

            setCurrent((currentIndex) => {
                const nextIndex =
                    event.deltaY > 0
                        ? currentIndex + 1
                        : currentIndex - 1;

                scrollToSection(nextIndex);
                return currentIndex;
            });
        };

        const handleTouchStart = (event: TouchEvent): void => {
            touchStartYRef.current =
                event.changedTouches[0]?.screenY ?? 0;
        };

        const handleTouchEnd = (event: TouchEvent): void => {
            if (isScrollingRef.current) {
                return;
            }

            const touchEndY =
                event.changedTouches[0]?.screenY ??
                touchStartYRef.current;

            const delta = touchStartYRef.current - touchEndY;

            setCurrent((currentIndex) => {
                if (delta > SWIPE_THRESHOLD) {
                    scrollToSection(currentIndex + 1);
                } else if (delta < -SWIPE_THRESHOLD) {
                    scrollToSection(currentIndex - 1);
                }

                return currentIndex;
            });
        };

        document.addEventListener("wheel", handleWheel);
        document.addEventListener("touchstart", handleTouchStart, {
            passive: true,
        });
        document.addEventListener("touchend", handleTouchEnd, {
            passive: true,
        });

        return () => {
            document.removeEventListener("wheel", handleWheel);
            document.removeEventListener(
                "touchstart",
                handleTouchStart,
            );
            document.removeEventListener("touchend", handleTouchEnd);
        };
    }, [scrollToSection]);
    
    return (
        <div>
            <div className={style.topbar}>
                <div className={style.topbarCenter}>{topBarText}</div>
                <div className={style.signOutButton} onClick={() => signOut()}>Sign Out</div>
            </div>

            <InfoPage sectionsRef={sectionsRef}/>
            <TrackerPage activityTypes={activityTypes} activityColors={activityColors} sectionsRef={sectionsRef} activityHistory={completedActivities} setActivityHistoryFn={setCompletedActivities}/>
            <StatPage activityColors={activityColors} sectionsRef={sectionsRef} activityHistory={completedActivities}/>

            <div className={style.pagination}>
                {Array.from({ length: SECTION_COUNT }, (_, index) => (
                    <div
                        key={index}
                        className={[
                            style.dot,
                            current === index ? style.active : "",
                        ]
                            .filter(Boolean)
                            .join(" ")}
                        onClick={() => scrollToSection(index)}
                    ></div>
                ))}
            </div>

            <div className={style.navArrows}>
                <div
                    className={style.arrow}
                    onClick={() => scrollToSection(current - 1)}
                >⬆</div>

                <div
                    className={style.arrow}
                    onClick={() => scrollToSection(current + 1)}
                >⬇</div>
            </div>
        </div>
    )
}
