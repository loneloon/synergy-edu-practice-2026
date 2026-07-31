import React, { ReactElement, useCallback, useEffect, useState } from "react";
import style from './InfoPage.less'
import TextSections from "./TextSections/TextSections";
import { helloText, howToText, planningAdviceText } from "./content";


interface InfoPageProps {
    sectionsRef: any;
}


const sections = [
    {
        id: "hello",
        title: "Hello",
        content: helloText,
    },
    {
        id: "howto",
        title: "How To",
        content: howToText,
    },
    {
        id: "advice",
        title: "Planning advice",
        content: planningAdviceText,
    },
];


export function InfoPage({sectionsRef}: InfoPageProps): ReactElement {
    return (
        <div
            ref={(element) => {
                sectionsRef.current[0] = element;
            }}
            className={style.infoPage}
            id="section1"
        >
            <TextSections sections={sections}/>
        </div>
    )
}
