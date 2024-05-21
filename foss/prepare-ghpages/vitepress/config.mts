import { defineConfig } from "vitepress";
import website from "../website.json";

const config = website as DataType;

export default defineConfig({
  title: config.title,
  description: config.description,
  themeConfig: {
    sidebar: config.sidebar,

    socialLinks: [
      {
        icon: "github",
        link: config.github,
      },
    ],
  },
});
