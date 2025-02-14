/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      container: {
        center: true,
        padding: '1rem',
      },
      colors: {
        neon: {
          blue: '#0066FF',    // More vibrant primary blue
          electric: '#00CCFF', // Intense electric cyan-blue
          accent: '#00FFFF',   // Bright cyan accent
          glow: '#000066'      // Deep blue for glow effects
        },
      },
      keyframes: {
        'neon-pulse': {
          '0%, 100%': { opacity: 1 },
          '50%': { opacity: 0.7 },
        },
        'neon-glow': {
          '0%, 100%': {
            'box-shadow': '0 0 30px rgba(0, 204, 255, 0.4), 0 0 60px rgba(0, 102, 255, 0.3)',
          },
          '50%': {
            'box-shadow': '0 0 50px rgba(0, 204, 255, 0.5), 0 0 100px rgba(0, 102, 255, 0.4)',
          },
        },
      },
      animation: {
        'neon-pulse': 'neon-pulse 2s ease-in-out infinite',
        'neon-glow': 'neon-glow 3s ease-in-out infinite',
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
      },
    },
  },
  plugins: [],
};