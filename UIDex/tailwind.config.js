/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}"
  ],
  theme: {
    extend: {
      colors: {
        'background-dark': '#121212',
        'background-light': '#1e1e1e',
        'primary': '#00c18c',
        'text-light': '#ffffff',
      },
      borderRadius: {
        'xl': '20px',
        'lg': '10px',
      },
      padding: {
        '4': '10px',
        '6': '15px',
        '8': '20px',
      },
      fontSize: {
        'base': '16px',
        'lg': '18px',
      },
    },
  },
  plugins: [],
}

