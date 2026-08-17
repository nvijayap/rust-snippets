# rust-snippets
Rust Snippets
## Writing to (stdout, stderr, file) and then reading from file
```
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {

  // writes a string to stdout
  println!("hello, rust universe!");

  // writes as string to stderr
  eprintln!("damn, encountered an error!");

  // writes a string to a file
  fs::write("out.txt", "just a line to go into out.txt\n")?;

  // Reads the entire file into a String; propagates errors with '?'
  let contents = fs::read_to_string("out.txt")?;
  println!("{}", contents);

  // will throw error if the file does not exist
  let contents = fs::read_to_string("foo.txt")?;
  println!("{}", contents);

  // indicates success
  Ok(())
}
```
## Capturing Environment Variable
```
use std::env;

fn main() {
    let key = "DATABASE_URL";
    
    // 1. Basic reading (will panic if missing)
    let db_url = env::var(key).unwrap();

    // 2. Safe pattern matching for missing variables
    match env::var(key) {
        Ok(val) => println!("{key} is set to: {val}"),
        Err(e) => println!("Could not read {key}: {e}"),
    }

    // 3. Providing a default value if missing
    let port = env::var("PORT").unwrap_or_else(|_| "8080".to_string());
}
```
## Capturing command-line args
```
use std::env;

fn main() {
    // Collect all arguments into a Vector of Strings
    let args: Vec<String> = env::args().collect();

    // The first argument (index 0) is always the path to the executable
    println!("Executable path: {}", args[0]);

    // Check if the user passed actual arguments
    if args.len() > 1 {
        println!("First user argument: {}", args[1]);
        println!("All user arguments: {:?}", &args[1..]);
    } else {
        println!("No user arguments provided.");
    }
}
```
## A Simple Trigger
```
pub struct User {
    name: String,
    age: u32,
}

impl User {
    // This acts as your trigger
    pub fn new(name: String, age: u32) -> Self {
        let user = Self { name, age };
        
        // Trigger your event here
        // note: whatever data comes in here can be sent asynchronously to any resource, like a database
        println!("Trigger: A new user named {} was created!", user.name);
        
        user
    }
}
```
## A Simple Closure
```
fn main() {
    // A simple closure that adds one to a number
    let add_one = |x: i32| x + 1;
    let result = add_one(5); // Returns 6
    println!("{}", result);
}
```
## Capturing the Environment
### Fn (Immutable Borrow)
```
fn main() {
    let name = "Rust";
    
    // Captures `name` by immutable reference (&T)
    let print_name = || println!("Hello, {}!", name);
    
    print_name();
    print_name(); // Can call again because `name` is still valid
}
```
### FnMut (Mutable Borrow)
```
fn main() {
    let mut count = 0;
    
    // Captures `count` by mutable reference (&mut T)
    let mut increment = || {
        count += 1;
        println!("Count: {}", count);
    };
    
    increment(); // Count: 1
    increment(); // Count: 2
}
```
### FnOnce (Take Ownership)
```
fn main() {
    let data = vec![1, 2, 3];
    
    // Uses the `move` keyword to take ownership of `data`
    let consume_data = move || {
        // note: whatever data comes in here can be sent asynchronously to any resource, like a database
        let _len = data.len();
        println!("Consumed data!");
    };
    
    consume_data();
    // consume_data(); // Error! `consume_data` cannot be called twice.
    // println!("{:?}", data); // Error! `data` was moved into the closure.
}
```
## Create File if Not Found
```
use std::fs::File;
use std::io::{self, ErrorKind};

fn get_or_create_file(path: &str) -> io::Result<File> {
    match File::open(path) {
        Ok(file) => Ok(file),
        Err(error) => match error.kind() {
            ErrorKind::NotFound => File::create(path),
            _ => Err(error), // Return any other error (e.g. permissions)
        },
    }
}

fn main() {
    let _file = get_or_create_file("output.txt").unwrap();
}
```
## Concatenate strings
```
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
  let concatenated_string = format!("{} {} {}", "so", "be", "it");
  println!("concatenated_string: {concatenated_string}");
  Ok(())
}
```
## Spawn a thread
```
use std::thread;

fn main() {
    // Spawn a new thread
    let handle = thread::spawn(|| {
        println!("Hello from the spawned thread!");
    });

    // Wait for the thread to finish executing
    handle.join().unwrap();
}
```
## How to use Box
```
use std::error::Error;
use std::fmt;

#[derive(Debug)]
struct MyError;

impl fmt::Display for MyError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "My custom error")
    }
}

impl Error for MyError {}

fn example_function() -> Result<(), Box<dyn Error>> {
    Err(Box::new(MyError))
}

fn main() {
  match example_function() {
    Ok(r) => println!("{:?}", r),
    Err(e) => println!("{e}"),
  }
}
```
## The idiomatic way of accepting both &str and String
```
// This function accepts both &str and String seamlessly
fn route_any_text<T: AsRef<str>>(param: T) {
    let text: &str = param.as_ref();
    println!("Processing text: {}", text);
}

fn main() {
    let my_str: &str = "hello";
    let my_string: String = String::from("world");

    // Both work perfectly
    route_any_text(my_str);
    route_any_text(my_string);
}
```
## True Routing (Distinct Behavior for &str and String)
```
// 1. Define a routing trait
trait TextRouter {
    fn route(self);
}

// 2. Implement behavior for &str
impl TextRouter for &str {
    fn route(self) {
        println!("Routed to the BORROWED (&str) handler: {}", self);
    }
}

// 3. Implement behavior for String
impl TextRouter for String {
    fn route(self) {
        println!("Routed to the OWNED (String) handler: {}", self);
    }
}

// 4. Create the entry point function
fn process_route<T: TextRouter>(param: T) {
    param.route();
}

fn main() {
    let borrowed: &str = "static_path";
    let owned: String = String::from("dynamic_path");

    // Executes &str logic
    process_route(borrowed); 

    // Executes String logic
    process_route(owned);    
}
```
## Checking type information
```
use std::any::type_name;

fn type_of<T>(_: T) -> &'static str {
    type_name::<T>()
}

fn main() {
    let a = 21; // Integer
    println!("{}", type_of(a)); // i32

    let b = 2.5; // Float
    println!("{}", type_of(b)); // f64
    
    let c = "hello";
    println!("{}", type_of(c)); // &str

    let d: String = "world".into();
    println!("{}", type_of(d)); // alloc::string::String
    
    struct S;
    let the_struct = S;
    println!("{}", type_of(the_struct)); // ...::main::S
}
```
## Calling C Functions from Rust
```
// Declare the external C library function
extern "C" {
    fn abs(input: i32) -> i32;
}

fn main() {
    // Calling the FFI function requires an unsafe block
    let result = unsafe { abs(-42) };
    println!("Absolute value from C: {}", result);
}
```
## Spawn a binary
```
use std::process::Command;

fn main() {
    // Spawn the binary
    let mut child = Command::new("mkdir")
        .arg("-p")
        .arg("/tmp/a")
        .spawn()
        .expect("failed to execute process");

    // Do other work while the child process runs...

    // Wait for the child process to finish and get its status
    let status = child.wait().expect("failed to wait on child");
    println!("Process finished with: {}", status);
}
```
## Without panicking, just show the error message
### Using `match`
```
let res: Result<i32, &str> = Err("file not found");

match res {
    Ok(val) => println!("Success: {}", val),
    Err(e) => println!("Error: {}", e), // Shows the err message safely
}
```
### Using `if let`
```
let res: Result<i32, &str> = Err("bad input");

if let Err(e) = res {
    println!("Error: {}", e);
}
```
## Mapping over an Iterator
```
fn main() {
    let numbers = vec![1, 2, 3];

    // .map() is safe and lazy; it transforms elements one by one
    let doubled: Vec<i32> = numbers
        .iter()
        .map(|x| x * 2)
        .collect();

    println!("{:?}", doubled); // Output: [2, 4, 6]
}
```
## Mapping over an Option
```
fn main() {
    let maybe_number: Option<i32> = Some(5);
    
    // Transforms the value inside Some, or safely returns None
    let doubled_option = maybe_number.map(|x| x * 2);

    println!("{:?}", doubled_option); // Output: Some(10)
    
    let empty: Option<i32> = None;
    println!("{:?}", empty.map(|x| x * 2)); // Output: None (no panic!)
}
```
## Filtering an Iterator
```
fn main() {
    let numbers = vec![1, 2, 3, 4, 5, 6];

    // .filter() takes a reference to the item (&&x)
    // We dereference it (*x) to check the value
    let evens: Vec<i32> = numbers
        .into_iter()
        .filter(|x| x % 2 == 0)
        .collect();

    println!("{:?}", evens); // Output: [2, 4, 6]
}
```
## Combining .filter and .map
```
fn main() {
    let numbers = vec![1, 2, 3, 4, 5, 6];

    let doubled_evens: Vec<i32> = numbers
        .into_iter()
        .filter(|x| x % 2 == 0) // Keeps: 2, 4, 6
        .map(|x| x * 2)        // Becomes: 4, 8, 12
        .collect();

    println!("{:?}", doubled_evens); // Output: [4, 8, 12]
}
```
## Vector and Array Sum
```
fn main() {
    let numbers = vec![1, 2, 3, 4, 5];
    
    // Using .sum() on an iterator
    let total: i32 = numbers.iter().sum();
    
    println!("Sum is: {}", total); // Sum is: 15
}
```
## Range Sum with Type Hint
```
fn main() {
    // Using turbofish syntax to specify the output type
    let sum: u32 = (1..=5).sum();
    
    println!("Sum of range: {}", sum); // Sum of range: 15
}
```
## Using turbofish syntax (::<...>)
```
fn main() {
    // 1. Parsing a string into an integer
    // Without turbofish, Rust doesn't know if you want a u32, i32, or f64
    let number = "42".parse::<i32>().unwrap();
    println!("Parsed number: {}", number);

    // 2. Collecting a iterator into a specific collection
    // Tells the compiler to group these numbers into a Vector
    let micro_animals = vec!["tardigrade", "nematode"];
    let animal_list = micro_animals.iter().collect::<Vec<&&str>>();
    println!("Animal list: {:?}", animal_list);
}
```
## Type Annotations
### Basic Syntax
```
let score: i32 = 100;                 // 32-bit signed integer
let pi: f64 = 3.14159;                // 64-bit floating point
let is_active: bool = true;           // Boolean
let greeting: &str = "Hello, Rust!";  // String slice
```
### Mandatory in Function Signatures
```
fn add_numbers(x: i32, y: i32) -> i32 {
    x + y // Return type is annotated after the '->'
}
```
### Mandatory in Struct and Enum Definitions
```
struct User {
    username: String,
    login_count: u64,
    is_active: bool,
}
```
### Constants and Statics
```
const MAX_POINTS: u32 = 100_000;
```
## About `static`
In Rust, the word static is used for three main things: declaring global variables with fixed memory locations, specifying a lifetime where data lives for the entire program, and defining trait bounds to ensure types do not contain temporary borrowed references.
## Built-In Iterator Methods
### Transforming Adapters
  1. .filter_map(): Runs a function that returns an Option, keeping only the Some values and unwrapping them at the same time.
  2. .enumerate(): Yields pairs of (index, element) as you loop through items.
  3. .take(n): Keeps only the first n items from the sequence.
  4. .skip(n): Bypasses the first n items and yields the rest.
  5. .zip(other): Blends two streams into pairs (a, b).
  6. .flatten(): Flattens nested collections (like a Vec<Vec<T>>) into a single level.
### Consuming Methods
  1. .collect(): Gathers items back into a collection like a Vec or HashMap.
  2. .fold(init, f): Accumulates a single final value by carrying an intermediate state through a closure. Aka `reduce`
  3. .any(predicate): Returns true if any element matches the condition.
  4. .all(predicate): Returns true if every element matches the condition.
  5. .find(predicate): Returns the first item that matches the condition as an Option.
  6. .count(): Counts how many items are left in the iterator.
