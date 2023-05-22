#[opengauss_bindgen::opengauss_bindgen]
fn fib(n: u64) -> u64 {
    if n <= 1 {
        n
    } else {
        let mut accumulator = 0;
        let mut last = 0;
        let mut current = 1;

        for _i in 1..n {
            accumulator = last + current;
            last = current;
            current = accumulator;
        }

        accumulator
    }
}
