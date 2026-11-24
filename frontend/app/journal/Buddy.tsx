import GlobalStyles from "@mui/material/GlobalStyles";
import { palette, sizes } from "~/palette";

const talkAnimation = "buddy-talk";
const bobAnimation = "buddy-bob";
const blinkAnimation = "buddy-blink";
const svgPartStyle = { transformBox: "fill-box" as const, transformOrigin: "center" };

export type BuddyExpression = "resting" | "talking" | "thinking";

export function Buddy({ size, expression }: { size: number; expression: BuddyExpression }) {
  const thinking = expression === "thinking";
  const pupilY = thinking ? 50 : 56;
  const pupilShine = thinking ? 48 : 54;
  const talkingStyle = (animation: string, milliseconds: number) =>
    expression === "talking"
      ? { ...svgPartStyle, animation: `${animation} ${milliseconds}ms ease-in-out infinite` }
      : svgPartStyle;

  return (
    <>
      <GlobalStyles
        styles={{
          [`@keyframes ${talkAnimation}`]: {
            "0%, 100%": { transform: "scaleY(0.35)" },
            "50%": { transform: "scaleY(1)" },
          },
          [`@keyframes ${bobAnimation}`]: {
            "0%, 100%": { transform: "translateY(0)" },
            "50%": { transform: "translateY(-2px)" },
          },
          [`@keyframes ${blinkAnimation}`]: {
            "0%, 92%, 100%": { transform: "scaleY(1)" },
            "96%": { transform: "scaleY(0.1)" },
          },
        }}
      />
      <svg role="img" aria-label="Your teacher" width={size} height={size} viewBox="0 0 120 120">
        <path d="M18 120 Q18 84 60 84 Q102 84 102 120 Z" fill={palette.teacher} />
        <path d="M30 120 Q30 98 44 92 L60 104 L76 92 Q90 98 90 120 Z" fill={palette.teacherEdge} />
        <path
          d="M40 84 Q60 96 80 84 L82 94 Q60 106 38 94 Z"
          fill={palette.action}
          stroke={palette.actionEdge}
          strokeWidth={2}
          strokeLinejoin="round"
        />
        <path d="M74 92 L84 112 L72 110 Z" fill={palette.action} />
        <g style={talkingStyle(bobAnimation, sizes.buddyBobMilliseconds)}>
          <circle cx={32} cy={58} r={7} fill={palette.buddySkinShade} />
          <circle cx={88} cy={58} r={7} fill={palette.buddySkinShade} />
          <circle cx={60} cy={56} r={28} fill={palette.buddySkin} />
          <path d="M36 70 Q60 92 84 70 Q76 84 60 84 Q44 84 36 70 Z" fill={palette.buddySkinShade} />
          <ellipse cx={58} cy={30} rx={31} ry={11} fill={palette.ink} />
          <ellipse cx={58} cy={27} rx={27} ry={8} fill={palette.teacherEdge} />
          <circle cx={58} cy={18} r={4} fill={palette.ink} />
          <path
            d="M41 44 Q47 40 53 43"
            stroke={palette.ink}
            strokeWidth={3}
            strokeLinecap="round"
            fill="none"
          />
          <path
            d={thinking ? "M67 40 Q73 35 79 39" : "M67 43 Q73 40 79 44"}
            stroke={palette.ink}
            strokeWidth={3}
            strokeLinecap="round"
            fill="none"
          />
          <g
            style={{
              ...svgPartStyle,
              animation: `${blinkAnimation} ${sizes.buddyBlinkMilliseconds}ms infinite`,
            }}
          >
            <ellipse cx={47} cy={54} rx={7} ry={8} fill={palette.surface} />
            <ellipse cx={73} cy={54} rx={7} ry={8} fill={palette.surface} />
            <circle cx={49} cy={pupilY} r={4} fill={palette.ink} />
            <circle cx={75} cy={pupilY} r={4} fill={palette.ink} />
            <circle cx={50.5} cy={pupilShine} r={1.5} fill={palette.surface} />
            <circle cx={76.5} cy={pupilShine} r={1.5} fill={palette.surface} />
          </g>
          <circle cx={40} cy={66} r={5} fill={palette.action} opacity={0.35} />
          <circle cx={80} cy={66} r={5} fill={palette.action} opacity={0.35} />
          {thinking ? (
            <path
              d="M52 74 Q60 69 68 74"
              stroke={palette.ink}
              strokeWidth={3}
              strokeLinecap="round"
              fill="none"
            />
          ) : (
            <g style={talkingStyle(talkAnimation, sizes.buddyTalkMilliseconds)}>
              <path d="M48 67 Q60 80 72 67 Z" fill={palette.ink} />
              <path d="M53 72 Q60 78 67 72 Q60 70 53 72 Z" fill={palette.action} />
            </g>
          )}
        </g>
      </svg>
    </>
  );
}
