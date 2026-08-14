import '@mui/material/Typography';
import '@mui/material/Grid';
import '@mui/material/ListItemText';
import '@mui/material/TextField';
import '@mui/material/List';

declare module '@mui/material/Typography' {
  interface TypographyOwnProps {
    fontWeight?: any;
  }
}

declare module '@mui/material/Grid' {
  interface GridBaseProps {
    item?: any;
    xs?: any;
    sm?: any;
    md?: any;
    lg?: any;
    xl?: any;
    container?: any;
    spacing?: any;
    alignItems?: any;
    justifyContent?: any;
  }
}

declare module '@mui/material/ListItemText' {
  interface ListItemTextProps {
    primaryTypographyProps?: any;
    secondaryTypographyProps?: any;
  }
}

declare module '@mui/material/TextField' {
  interface BaseTextFieldProps {
    InputProps?: any;
    inputProps?: any;
    InputLabelProps?: any;
  }
  interface StandardTextFieldProps {
    InputProps?: any;
    inputProps?: any;
    InputLabelProps?: any;
  }
  interface FilledTextFieldProps {
    InputProps?: any;
    inputProps?: any;
    InputLabelProps?: any;
  }
  interface OutlinedTextFieldProps {
    InputProps?: any;
    inputProps?: any;
    InputLabelProps?: any;
  }
}

declare module '@mui/material/List' {
  interface ListOwnProps {
    size?: any;
  }
}
