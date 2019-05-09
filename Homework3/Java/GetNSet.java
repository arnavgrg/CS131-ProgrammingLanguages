//An int array in which elements may be updated atomically.
import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSet implements State {
    //private byte[] value;
    private AtomicIntegerArray value;
    private byte maxval;

    //Function to create an atomic integer array from a byte array
    private void set_vals(byte[] val){
        //Use this constructor instead of the alternate so that
        //we can use the set and get method as mentioned in the spec
        value = new AtomicIntegerArray(val.length);
        for (int i=0; i<val.length; i+=1){
            //set​(int i, int newValue)
            //Sets the element at index i to newValue
            value.set(i,v[i]);
        }
    }

    //Return type needs to be a byte array since we now want
    //to create a regular byte array from an atomic integer array
    private byte[] get_array(){
        byte[] byte_array = new byte[value.length()];
        for (int i=0; i < value.length(); i++){
            //Need to typecast 
            byte_array[i] = (byte) value.get(i);
        }
        return byte_array;
    }

    GetNSet(byte[] v) { set_vals(v); maxval = 127; }

    GetNSet(byte[] v, byte m) { set_vals(v); maxval = m; }

    public int size() { return value.length(); }

    //Returns the byte array
    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
	    if (value.get(i) <= 0 || value.get(j) >= maxval) {
	        return false;
	    }
	    value.set(i, value.get(i)-1);
	    value.set(j, value.get(j)+1);
	    return true;
    }
}
