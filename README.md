# rust-snippets

`Rust` Snippets - A collection of `Rust` programs and some very brief docs.

## Acknowledgment

My sincere thanks to `Google` for making `information` easily available to the masses and for open-sourcing many software.

And, of course, to the `Rust Community`

## As of 2026-08-17 ...

With the advent of AI-assisted `coding`, now it is all about `creativity` and `imagination` in gathering and presenting code and paving the way for `hierarchical and/or chained AI` systems.

## Writing to (stdout, stderr, file) and then reading from file

```
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {

  // writes a string to stdout
  println!("hello, rust universe!");

  // writes a string to stderr
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

## Exercise above

```
Save above into a file called main.rs

$ touch foo.txt; rustc main.rs && ./main # no error message

$ rm -f foo.txt; rustc main.rs && ./main # shows error message
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
        // `Note`: whatever data comes in here can be sent asynchronously to any resource, like a (distributed) database/datastore/storage-system or a (distributed) messaging system.
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
     
## Using Iterator::fold

```
fn main() {
    // 1. Summing a list of numbers
    let numbers = vec![1, 2, 3, 4, 5];
    
    let sum = numbers.iter().fold(0, |accumulator, &item| {
        accumulator + item
    });
    
    println!("The sum is: {}", sum); // Output: 15

    // 2. Building a string from a vector of words
    let words = vec!["Rust", "is", "fast", "and", "safe"];
    
    let sentence = words.iter().fold(String::new(), |mut acc, &word| {
        if !acc.is_empty() {
            acc.push(' ');
        }
        acc.push_str(word);
        acc
    });
    
    println!("{}", sentence); // Output: Rust is fast and safe
}
```

## Reading from `stdin`

```
use std::io;

fn main() {
    println!("Please enter some text:");
    
    let mut input = String::new();
    
    io::stdin()
        .read_line(&mut input)
        .expect("Failed to read line"); // Handles potential I/O errors

    // Note: read_line includes the trailing newline character '\n'
    println!("You typed: {}", input.trim()); 
}
```

## exec

```
use std::process::Command;
use std::os::unix::process::CommandExt;

fn main() {
    // This will completely replace your program with "echo"
    let error = Command::new("echo")
        .arg("Hello from the other side!")
        .exec();

    // This line only runs if exec fails (e.g., command not found)
    println!("Error running exec: {}", error);
}
```

### Rc

```
In Rust, `Rc` stands for `Reference Counted`. 

It is a smart pointer type (Rc<T>) that enables multiple parts of your program to
share ownership of the same data on the heap within a single thread. 

It tracks how many owners exist and deletes the data when that count hits zero.
```

## Arc

```
In Rust, `Arc` stands for `Atomically Reference Counted`. 
It is a thread-safe smart pointer that enables shared ownership of a value allocated on the heap.

Normally, Rust's strict ownership model dictates that a value can only have one owner at a time. 
Arc bypasses this restriction safely in `multithreaded` environments by tracking
how many references to the data exist.
```

## Cow

```
In Rust, Cow stands for Clone-on-Write (found in std::borrow::Cow).
It is a smart pointer that acts like a wrapper for data.

It lets you handle situations where data might be borrowed or owned, and it only clones (copies)
the data into a new, owned memory block if you actually try to change it.
```

## why does thread::spawn use move

```
Rust's std::thread::spawn uses the move keyword because new threads can outlive the current function.
A move closure takes full ownership of variables it captures from outside,
preventing dangling references if the parent function finishes before the spawned thread.
```

## match handle.join

```
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        "Thread work completed!"
    });

    match handle.join() {
        Ok(result) => println!("Success! Thread returned: {}", result),
        Err(_) => println!("The spawned thread panicked!"),
    }
}
```

## Arithmetic Progression (AP)

An arithmetic progression (AP) is a sequence where the difference between consecutive terms is constant. In Rust, you can generate an AP using standard iterators, calculate the n-th term, or check if a sequence forms an AP using basic loops or specialized crates like use-series.

### Generating an AP Using Iterators

```
fn generate_ap(first: i32, diff: i32, count: usize) -> Vec<i32> {
    std::iter::successors(Some(first), move |&prev| Some(prev + diff))
        .take(count)
        .collect()
}

fn main() {
    let ap = generate_ap(2, 3, 5); // Starts at 2, step 3, 5 elements
    println!("{:?}", ap); // Output: [2, 5, 8, 11, 14]
}
```

To overcome a value move in Rust, you can use borrowing (& or &mut), implement the Copy trait, explicitly clone the data, or use shared ownership smart pointers like Rc or Arc.

## Borrowing with References

Instead of transferring ownership, pass a reference so the original variable remains valid and usable.

```
fn print_text(s: &String) {
    println!("{}", s);
}

fn main() {
    let s1 = String::from("hello");
    print_text(&s1); // Borrowing s1 instead of moving it
    println!("{}", s1); // Still valid here!
}
```

Behind the scenes in Rust, borrowing is a compile-time check with zero cost at runtime. The compiler uses a system called the borrow checker and lifetimes to track how long references are valid. This prevents data races and crashes before your code ever runs.

## Implementing or using `copy`

Types that have fixed size stored on the stack (like numbers) implement the Copy trait. Instead of moving, Rust automatically copies them. You can derive Copy for simple custom structs.

```
#[derive(Clone, Copy)]
struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let p1 = Point { x: 1, y: 2 };
    let p2 = p1; // Copied, not moved!
    println!("p1 is still valid: {}", p1.x);
}
```

## Cloning the data

If you need absolute ownership of a new variable and cannot share references, create a complete duplicate using .clone().

```
fn main() {
    let s1 = String::from("hello");
    let s2 = s1.clone(); // Deep copy of the heap data
    println!("s1: {}, s2: {}", s1, s2); // Both are valid
}
```

## Shared ownership (Rc/Arc)

When multiple parts of your program need joint ownership of data, wrap it in a Reference Counted smart pointer (Rc for single-threaded, Arc for multi-threaded).

```
use std::rc::Rc;

fn main() {
    let s1 = Rc::new(String::from("hello"));
    let s2 = Rc::clone(&s1); // Increments reference count
    
    println!("Strong count: {}", Rc::strong_count(&s1));
}
```

## Using `Arc` - Real-World Code Example

```
use std::sync::Arc;
use std::thread;
use std::time::Duration;

// Shared configuration for our application
struct AppConfig {
    app_name: String,
    timeout_seconds: u64,
}

fn main() {
    // Wrap the config in an Arc so it can be safely shared across threads
    let config = Arc::new(AppConfig {
        app_name: String::from("FastServer"),
        timeout_seconds: 5,
    });

    let mut handles = vec![];

    // Spawn 3 worker threads
    for i in 1..=3 {
        // Clone the Arc pointer for this thread
        // This increments the reference count atomically, not the underlying data
        let config_clone = Arc::clone(&config);

        let handle = thread::spawn(move || {
            // Access shared data safely from the new thread
            println!(
                "Worker {} started for {}. Timeout is {}s.",
                i, config_clone.app_name, config_clone.timeout_seconds
            );
            
            thread::sleep(Duration::from_millis(100));
            
            println!("Worker {} finished.", i);
        });

        handles.push(handle);
    }

    // Wait for all worker threads to finish
    for handle in handles {
        handle.join().unwrap();
    }

    println!("All workers done. Program exiting.");
}
```

## Using `Arc` with `Mutex` - Real-World Code Example

```
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

// The data structure we want to share and mutate across threads
#[derive(Debug)]
struct JobStatus {
    progress: u32,
    state: &'static str,
}

fn main() {
    // 1. Initialize the tracker wrapped in a Mutex, then an Arc
    let job_tracker: Arc<Mutex<HashMap<String, JobStatus>>> = Arc::new(Mutex::new(HashMap::new()));

    let mut thread_handles = vec![];

    // 2. Spawn 3 background worker threads
    for i in 1..=3 {
        // Clone the Arc pointer for the new thread (increases reference count)
        let tracker_clone = Arc::clone(&job_tracker);
        let job_id = format!("job_{}", i);

        let handle = thread::spawn(move || {
            // Initialize the job status in the map
            {
                // lock() blocks until this thread exclusively owns the data
                let mut map = tracker_clone.lock().unwrap();
                map.insert(job_id.clone(), JobStatus { progress: 0, state: "Pending" });
                // The lock is released here automatically when `map` goes out of scope
            }

            // Simulate background work increments
            for step in 1..=5 {
                thread::sleep(Duration::from_millis(100)); // Simulate time-consuming work
                
                // Acquire the lock to update progress
                let mut map = tracker_clone.lock().unwrap();
                if let Some(job) = map.get_mut(&job_id) {
                    job.progress = step * 20;
                    job.state = if step == 5 { "Completed" } else { "Running" };
                }
            }
        });

        thread_handles.push(handle);
    }

    // 3. Simultaneously, simulate the main thread acts like an API reading the status
    for _ in 0..3 {
        thread::sleep(Duration::from_millis(150));
        
        // Acquire lock just to read the current state
        let map = job_tracker.lock().unwrap();
        println!("--- Live API Snapshot ---");
        for (id, status) in map.iter() {
            println!("{}: {}% ({})", id, status.progress, status.state);
        }
    }

    // 4. Ensure all worker threads complete their execution cleanly
    for handle in thread_handles {
        handle.join().unwrap();
    }

    // Print final report
    println!("\nFinal State: {:?}", job_tracker.lock().unwrap());
}
```

## Interacting with K8s (Kubernetes), Test with `minikube`

`Cargo.toml`

```
[package]
name = "mk"
version = "0.1.0"
edition = "2024"

[dependencies]
k8s-openapi = { version = "0.28.0", features = ["v1_36"] }
kube = "4.2.0"
tokio = { version = "1.53.1", features = ["full"] }
```

`src/main.rs`

```
use kube::{Client, Api};
use k8s_openapi::api::core::v1::Pod;

#[tokio::main]
async fn main() -> Result<(), kube::Error> {
    // Initialize the Kubernetes client from the default ~/.kube/config (Minikube context)
    let client = Client::try_default().await?;

    // Define an API accessor for Pods in the "default" namespace
    let pods: Api<Pod> = Api::namespaced(client, "default");

    // List the pods currently running in Minikube
    for p in pods.list(&Default::default()).await? {
        println!("Pod Name: {}", p.metadata.name.unwrap_or_default());
    }

    Ok(())
}
```

## Number of Logical CPUs

`Cargo.toml`

```
[package]
name = "lcpus"
version = "0.1.0"
edition = "2024"

[dependencies]
num_cpus = "1.17.0"
```

`src/main.rs`

```
fn main() {
    let cpus = num_cpus::get();
    println!("cpus: {cpus}");
}
```

## RAM - Total, Used

`Cargo.toml`

```
[package]
name = "ram"
version = "0.1.0"
edition = "2024"

[dependencies]
sysinfo = "0.39.6"
```

`src/main.rs`

```
use sysinfo::System;

fn main() {
    // Create and load system information
    let mut sys = System::new_all();

    // Refresh memory components
    sys.refresh_memory();

    // Get total and used memory in bytes
    let total_ram = sys.total_memory();
    let used_ram = sys.used_memory();

    println!("Total RAM: {} bytes", total_ram);
    println!("Used RAM: {} bytes", used_ram);
    
    // Convert bytes to gigabytes (GB)
    let gb = 1024 * 1024 * 1024;
    println!("Total RAM: {} GB", total_ram / gb);
}
```

## .
