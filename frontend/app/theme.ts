import { createTheme } from "@mui/material/styles";
import { fonts, palette } from "~/palette";

const cornerRadius = 16;
const edgeHeight = 4;
const pressedEdgeHeight = 2;

export const theme = createTheme({
  palette: {
    background: { default: palette.ground, paper: palette.surface },
    text: { primary: palette.ink },
    primary: { main: palette.action, contrastText: palette.ink },
    error: { main: palette.error },
    success: { main: palette.fix },
  },
  shape: { borderRadius: cornerRadius },
  typography: {
    fontFamily: fonts.reading,
    h1: { fontFamily: fonts.display, fontWeight: 600, fontSize: "2.5rem" },
    h2: { fontFamily: fonts.display, fontWeight: 600, fontSize: "1.5rem" },
    button: { fontFamily: fonts.display, fontWeight: 600, textTransform: "none" },
  },
  components: {
    MuiButton: {
      defaultProps: { disableElevation: true, variant: "contained" },
      styleOverrides: {
        root: {
          borderRadius: cornerRadius,
          border: `2px solid ${palette.actionEdge}`,
          boxShadow: `0 ${edgeHeight}px 0 ${palette.actionEdge}`,
          "&:active": {
            transform: `translateY(${edgeHeight - pressedEdgeHeight}px)`,
            boxShadow: `0 ${pressedEdgeHeight}px 0 ${palette.actionEdge}`,
          },
        },
      },
    },
    MuiPaper: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        root: {
          border: `2px solid ${palette.surfaceEdge}`,
          boxShadow: `0 ${edgeHeight}px 0 ${palette.surfaceEdge}`,
        },
      },
    },
  },
});
