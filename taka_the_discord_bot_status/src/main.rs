use axum::{Router, routing::get, response::{IntoResponse, Html}};


const INDEX_HTML: &str = include_str!("../assets/index.html");
const STATUS_BOX: &str = r#"<a href="{{href}}" id="status_box">
        <h2 id="title"> {{title}} </h2>
        <div id="status" class="{{status_class}}"> {{status}} </div> 
</a> "#;

pub struct StatusWebsite {
    pub url: &'static str,
    pub title: &'static str,
    pub description: &'static str
}

const WEBSITES: [StatusWebsite; 2] = [
    StatusWebsite {
        url: "https://bot.takathedinosaur.tech/health",
        title: "Discord bot",
        description: "A discord bot I made specifically for my discord server to make my own sheetbot and it also got some hiyajo maho functionalities."
    },
    StatusWebsite {
        url: "https://htmlserver.takathedinosaur.tech/health",
        title: "HTML Server",
        description: "A server I use to generate teto and tetra commands. It might someday get replaced with generating graphics directly from rust, but css is easier."
    },
];

#[tokio::main]
async fn main() {
    let app = Router::new()
    // `GET /` goes to `root`
    .route_service("/", get(health_status))
    .route("/index.html", get(health_status))
    .route_service("/index.css", tower_http::services::ServeFile::new("./assets/index.css"));

    // run our app with hyper
    let _ = axum::Server::bind(&"0.0.0.0:8080".parse().unwrap())
        .serve(app.into_make_service())
        .await;
}


fn ok_status(website: &StatusWebsite) -> String {
    return STATUS_BOX.replacen("{{href}}", website.url, 1).replacen("{{title}}", website.title, 1).replacen("{{status_class}}", "ok", 1).replacen("{{status}}", "Online", 1)
}

fn error_status(website: &StatusWebsite) -> String {
    return STATUS_BOX.replacen("{{href}}", website.url, 1).replacen("{{title}}", website.title, 1).replacen("{{status_class}}", "offline", 1).replacen("{{status}}", "Offline", 1)

}

async fn health_status() -> impl IntoResponse {
    let mut str: String = String::new();
    for website in WEBSITES {
        str += &match reqwest::get(website.url).await {
            Ok(_) => ok_status(&website),
            Err(_) => error_status(&website)
        };
    }
    println!("{str}");
    Html(INDEX_HTML.clone().replacen("{{health_status}}", &str, 1))
}


