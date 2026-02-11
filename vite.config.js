import tailwindcss from '@tailwindcss/vite';
import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    tailwindcss({
      //   preflight: false,
      //   scan: {
      //     dirs: ['./src'], // all files in the cwd
      //     fileExtensions: ['bs.js'], // also enabled scanning for js/ts
      //   },
      config: {
        // safelist: ['prose', 'prose-sm', 'm-auto'],
        // darkMode: false, // or 'media' or 'class'
        // plugins: [pluginTypography],
        theme: {
          extend: {
            animation: {
              blink: 'blink 1s infinite',
              change: 'change 35s linear forwards 1',
              fadein: 'fadein 4.5s ease-in forwards 1',
              ping1: 'ping1 1s cubic-bezier(0, 0, 0.2, 1) infinite',
              rotate: 'rotate 2.5s linear infinite',
            },
            fontFamily: {
              anon: 'Anonymous Pro, monospace',
              arch: 'Architects Daughter, cursive',
              flow: 'Indie Flower, cursive',
              fred: 'Fredericka the Great, cursive',
              luck: 'Luckiest Guy, cursive',
              over: 'Overpass, sans-serif',
              perm: 'Permanent Marker, cursive',
            },
            keyframes: {
              blink: {
                '0%, 100%': { transform: 'translateY(-25%)' },
                '30%': { opacity: '0.4' },
                '50%': { transform: 'translateY(0)', opacity: '1' },
                '79%': { opacity: '0.5' },
              },
              change: {
                '100%': { 'stroke-dashoffset': '1000' },
              },
              fadein: {
                to: { opacity: '0.55' },
              },
              ping1: {
                '0%': {
                  opacity: '0',
                },
                '15%, 30%': {
                  opacity: '1',
                },
                '85%, 100%': {
                  opacity: '0',
                },
              },
              rotate: {
                to: { filter: 'hue-rotate(360deg)' },
              },
            },
            screens: {
              newgmimg: '459px', //11/12*459=421
              tablewidth: '550px',
              desk: '1440px',
            },
            textShadow: {
              lead: '0px 2px 2px #abc4d0',
              win: '0px 0px 3px #f5f5f4',
            },
          },
        },
      },
    }),
    react({
      include: ['**/*.res.mjs'],
    }),
  ],
  server: {
    headers: {
      'content-security-policy-report-only':
        "default-src 'none'; img-src 'self'; script-src 'self' 'report-sample' 'unsafe-inline'; connect-src 'self' https://yzcnlmnrwxmbvrjoupkw.supabase.co wss://yzcnlmnrwxmbvrjoupkw.supabase.co data: http://localhost:5173; font-src https://fonts.gstatic.com; style-src 'self' 'report-sample' 'unsafe-inline' https://fonts.googleapis.com; report-uri http://localhost:5173/; worker-src 'self' blob: http://localhost:5173;",
    },
    watch: {
      // We ignore ReScript build artifacts to avoid unnecessarily triggering HMR on incremental compilation
      ignored: ['**/lib/bs/**', '**/lib/ocaml/**', '**/lib/rescript.lock'],
    },
  },
});
