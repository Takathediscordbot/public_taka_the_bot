/**
 * @type {typeof document.querySelector}
 */
const $ = document.querySelector.bind(document);
/**
 * @type {typeof document.querySelectorAll}
 */
const $$ = document.querySelectorAll.bind(document);
/**
 * @type {typeof document.getElementById}
 */
const $$$ = document.getElementById.bind(document);

import * as Status from "./status.js"
const root = $$$("app_root");
const websites = [{title: "Tetrio HTML Server", url: "https://htmlserver.takathedinosaur.tech/health"}, {title: "Discord Bot", url: "https://bot.takathedinosaur.tech/health"}]; 

for await(const website of websites) {
    await Status.createStatus(root, website.title, website.url, "A cool website!");
}



