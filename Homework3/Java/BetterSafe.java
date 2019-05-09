/*A reentrant mutual exclusion Lock with the same basic behavior and 
semantics as the implicit monitor lock accessed using synchronized methods 
and statements, but with extended capabilities.*/
//Essentially like a mutex lock seen in C for synchronization
import java.util.concurrent.locks.ReentrantLock;

/* 
 class X {
   private final ReentrantLock lock = new ReentrantLock();
   // ...

   public void m() {
     lock.lock();  // block until condition holds
     try {
       // ... method body
     } finally {
       lock.unlock()
     }
   }
 }
*/

class BetterSafe implements State {
    private byte[] value;
    private byte maxval;
    /*When a variable is declared with final keyword, its value can't be 
    modified, essentially, a constant. This ensures it can't be saved 
    after it is defined, which is a good promise to have.*/
    private final ReentrantLock lock = new ReentrantLock();

    BetterSafe(byte[] v) { value = v; maxval = 127; }

    BetterSafe(byte[] v, byte m) { value = v; maxval = m; }

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
        //Close the lock to mark critical section
        lock.lock();
	      if (value[i] <= 0 || value[j] >= maxval) {
            //Incase the value is out of bounds, we don't want to hold 
            //resources
            //Free resources by unlocking the mutex lock
            lock.unlock();
	        return false;
	      }
	      value[i]--;
        value[j]++;
        //Open the lock to mark end of critical section
        lock.unlock();
	    return true;
    }
}