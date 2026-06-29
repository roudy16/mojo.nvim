def main():
    print("Hello, debug!")

    var counter: Int = 0
    for i in range(5):
        counter += i + 1
        print("Step", i, "counter =", counter)

    print("\nFinal counter:", counter)
