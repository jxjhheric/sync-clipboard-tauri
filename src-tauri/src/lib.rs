extern crate alloc;

use alloc::format;
use alloc::string::String;
use serde::{Deserialize, Serialize};

// Learn more about Tauri commands at https://tauri.app/develop/calling-rust/
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SharedData {
    pub text: Option<String>,
    pub files: Vec<String>,
}

#[tauri::command]
fn handle_share_intent(text: Option<String>, files: Vec<String>) -> Result<(), String> {
    if text.is_some() || !files.is_empty() {
        println!("Share intent received: text={:?}, files={:?}", text, files);
        Ok(())
    } else {
        Err("No content shared".to_string())
    }
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_sharetarget::init())
        .plugin(tauri_plugin_http::init())
        .plugin(tauri_plugin_toast::init())
        .plugin(tauri_plugin_fs::init())
        .plugin(tauri_plugin_process::init())
        .plugin(tauri_plugin_quicktile::init())
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_clipboard_manager::init())
        .plugin(tauri_plugin_deep_link::init())
        .invoke_handler(tauri::generate_handler![greet, handle_share_intent])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
