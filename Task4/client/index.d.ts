declare module "*.css" {
  const content: { [className: string]: string };
  export default content;
}

declare module "*.scss" {
  const content: { [className: string]: string };
  export default content;
}

declare module "*.less" {
  const content: { [key: string]: string };
  export default content;
}

// as per https://github.com/facebook/create-react-app/blob/4604c5e52c4fbac5c450ac0e58382775e24f3220/packages/react-scripts/lib/react-app.d.ts#L42-L49
declare module "*.svg" {
  import * as React from "react";
  export const ReactComponent: React.FunctionComponent<
    React.SVGProps<SVGSVGElement>
  >;
  const src: string;
  export default src;
}

declare module "*.png" {
  const src: string;
  export default src;
}

declare module "*.wav" {
  const src: string;
  export default src;
}

declare module "*.ogg" {
  const src: string;
  export default src;
}

declare module "*.mp3" {
  const src: string;
  export default src;
}

declare type RGBAColor = [number, number, number, number?];
