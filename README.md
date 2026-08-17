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
