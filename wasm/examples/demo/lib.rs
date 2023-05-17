use wasm_bindgen::prelude::*

#[wasm_bindgen]
pub fn encrypt(data: String, key: String) -> String {
    use magic_crypt::MagicCryptTrait;
    let mc = magic_crypt::new_magic_crypt!(key, 256);
    mc.encrypt_str_to_base64(data)
}

#[wasm_bindgen]
pub fn decrypt(data: String, key: String) -> String {
    use magic_crypt::MagicCryptTrait;
    let mc = magic_crypt::new_magic_crypt!(key, 256);
    mc.decrypt_base64_to_string(data).unwrap_or_else(|_| "ACCESS DENIED".to_string())
}
