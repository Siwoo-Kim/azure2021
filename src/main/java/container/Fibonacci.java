package container;

public class Fibonacci {
    
    public static void main(String[] args) {
        int N = Integer.parseInt(args[0]);
        System.out.println(fibonacci(N));
    }

    private static long fibonacci(int n) {
        if (n == 0 || n == 1) return n;
        return fibonacci(n-2) + fibonacci(n-1);
    }
    
}
