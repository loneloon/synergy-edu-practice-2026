import { ReactElement, useState } from "react";
import style from "./TextSections.less";
import React from "react";

export type TextSection = {
    id: string;
    title: string;
    content: string;
};

type TextSectionsProps = {
    sections: TextSection[];
};

export default function TextSections({
    sections,
}: TextSectionsProps): ReactElement | null {
    const [activeSectionId, setActiveSectionId] = useState<string>(
        sections[0]?.id ?? ""
    );

    if (sections.length === 0) {
        return null;
    }

    const activeSection =
        sections.find((section) => section.id === activeSectionId) ??
        sections[0];

    return (
        <div className={style.textViewer}>
            <div className={style.tabs}>
                {sections.map((section) => {
                    const isActive = section.id === activeSection.id;

                    return (
                        <div
                            key={section.id}
                            className={`${style.tab} ${
                                isActive ? style.activeTab : ""
                            }`}
                            role="button"
                            tabIndex={0}
                            onClick={() => setActiveSectionId(section.id)}
                            onKeyDown={(event) => {
                                if (
                                    event.key === "Enter" ||
                                    event.key === " "
                                ) {
                                    setActiveSectionId(section.id);
                                }
                            }}
                        >
                            {section.title}
                        </div>
                    );
                })}
            </div>

            <div className={style.content}>
                <h2 className={style.title}>{activeSection.title}</h2>

                <div className={style.text}>
                    {activeSection.content}
                </div>
            </div>
        </div>
    );
}
