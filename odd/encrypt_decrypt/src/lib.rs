use opengauss_bindgen::*;
use magic_crypt::{new_magic_crypt, MagicCryptTrait};

#[opengauss_bindgen::opengauss_bindgen]
pub fn encrypt(data: String, key: String) -> String {
    let mc = new_magic_crypt!(key, 256);
    mc.encrypt_str_to_base64(data)
}

#[opengauss_bindgen::opengauss_bindgen]
pub fn decrypt(data: String, key: String) -> String {
    let mc = new_magic_crypt!(key, 256);
    mc.decrypt_base64_to_string(data)
        .unwrap_or("[ACCESS DENIED]".to_owned())
}
