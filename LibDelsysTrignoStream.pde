import processing.net.*;
import java.util.Arrays;
import java.nio.ByteBuffer;

// para a versao 1.0 do SDK

class LibDelsysTrignoStream {  
  
  private Delsystcp comm;
  
  private long lastSampleTimeMillis;
  
  private float samplingFrequency;
  
  private Sample bufferedSample;
  
  public LibDelsysTrignoStream(PApplet mainApp) throws DelsysTrignoNotDetectedError {
    comm = new Delsystcp(mainApp);
    comm.connect();
    comm.SetDataFormatBigEndian();
    samplingFrequency = comm.GetSamplingRate();
    comm.start();
    lastSampleTimeMillis = System.currentTimeMillis(); // rough approximation
  }
  
  public Sample readSample() {
    if (bufferedSample != null) {
      Sample toReturn = bufferedSample;
      bufferedSample = null;
      return toReturn;
    }

    byte[] packet = comm.readPacket();
    while(packet == null){
      packet = comm.readPacket();
    }

    return processEMGPacket(packet);
  }
  
  private Sample processEMGPacket(byte[] packet){
    
    float[][] sensorData = new float[packet.length/64][16];
    int[][] sensorData_Int = new int[packet.length/64][16];

    synchronized (this){
    // Demultiplex, parse the byte array, and add the appropriate samples to the history buffer.
      int j = 0;
      int k = 0;
      for (int i = 0; i < packet.length/4; i++){
          sensorData[j][k] = ByteBuffer.wrap(packet, 4 * i, 4).getFloat();
          sensorData_Int[j][k] = int(sensorData[j][k]*127000/5.5);
          k++;
          if ((i+1) % 16 == 0){
            j++;
            k=0;
          }
          if ((i+1) % 64 ==0){
            j=0;
          }
      }
    }

    int[] temp = sensorData_Int[0].clone();
    float [] temp2 = sensorData[0].clone();
    //lastSampleTimeMillis += float(packet.length/128)/samplingFrequency;
    lastSampleTimeMillis++;
    Sample s1 = new Sample(lastSampleTimeMillis, temp, temp2);
    //temp = sensorData_Int[1].clone();
    //Sample s2 = new Sample(lastSampleTimeMillis, temp);

    // return the first sample, buffer the second
    //bufferedSample = s2;
    bufferedSample = null;
    // return the first sample, buffer the second
    return s1;
  }
  

}


class Sample {
  public long timestamp;
  public int[] sensorData;
  public float[] sensorDataFloat;

  public Sample(long timestamp, int[] sensorData, float[] sensorDataFloat) {
    this.timestamp = timestamp;
    this.sensorData = sensorData;
    this.sensorDataFloat = sensorDataFloat;
  }
}


private class Delsystcp{
  // Endereco do Servidor 
  final String HOST = "127.0.0.1";
  final int BASE_PORT = 50040;
  final int EMG_PORT = 50041;
  
  // When attempting to auto-detect the myo dongle, a request for discovery
  // messages is sent across each serial port prompting the armband to
  // broadcast its identity. A port will be ruled-out after this duration of
  // time.
  final int DISCOVERY_TIMEOUT_MILLIS = 2000;

  // During auto-detection, we cannot be sure that the port we are
  // communicating across is connected to an armband, meaning that we may never
  // receive a response. Give up trying to receive a packet after this
  // duration of time.
  //final int PACKET_TIMEOUT_MILLIS = 50;
  
  PApplet mainApp; //<>// //<>//
  
  private Client Trigno_Base;
  private Client Trigno_Emg;
  
  public Delsystcp(PApplet mainApp) throws DelsysTrignoNotDetectedError{
    this.mainApp = mainApp;
    connect();
  }
  
  public void connect() throws DelsysTrignoNotDetectedError {
    if ((Trigno_Base == null) && (Trigno_Emg == null))
      establishConnection();
      
      // clean up any residue from previous runs
    Trigno_Base.clear();
  }
  
  public void SetTriggerStartOn(){
    write("TRIGGER START ON");
  }
  
  public void SetTriggerStartOff(){
    write("TRIGGER START OFF");
  }
  
  public void SetTriggerStopOn(){
    write("TRIGGER STOP ON");
  } //<>// //<>//
  public void SetTriggerStopOff(){
    write("TRIGGER STOP OFF");
  }
  
  public void GetTriggerState(){
    write("TRIGGER?");
    println(GetAnswer());
  }
  public void SetSamplingRate(){}
  
  public float GetSamplingRate(){
    //write("RATE?");
    //String ans = GetAnswer().replace(',','.');
    //return Float.parseFloat(ans.substring(2));
    return 2000.0f;
  }
  public void SetDataFormatBigEndian(){
    write("ENDIAN BIG");
  }
  
  public void SetDataFormatLittleEndian(){
    write("ENDIAN LITTLE");
  }
  
  public void GetDataFormat(){
    write("ENDIANNESS?");
    println(GetAnswer());
  }
  
  public void stop(){
    write("STOP");
  }
  public void start(){
    write("START");
  }
  
  private String GetAnswer(){
    delay(5);
    return this.Trigno_Base.readString();
  } 
  
  private void write(String message){
    delay(5);
    this.Trigno_Base.write(message + "\r\n\r\n");
  }
  
  private void establishConnection() throws DelsysTrignoNotDetectedError{
    try{
      this.Trigno_Base = new Client(mainApp, HOST , BASE_PORT);
      this.Trigno_Emg = new Client(mainApp, HOST , EMG_PORT);
    }catch(RuntimeException e){
      //
    }
    
    // wait for discovery response until timeout
    long startTime = millis();
    while (millis() < startTime+DISCOVERY_TIMEOUT_MILLIS) {
      String response = GetAnswer();
      if (response != null ) {
        println(response);
        return;
      }
    }
    // couldn't find a connected armband, abort
    throw(new DelsysTrignoNotDetectedError());
  }
  
  public void disconnect(){
    assert(Trigno_Base != null);
    assert(Trigno_Emg != null);
    
   
    if(Trigno_Base.available() > 0){
        Trigno_Base.clear();
        Trigno_Emg.clear();
    }
    write("QUIT");
    //Trigno_Base.stop();
    //Trigno_Emg.stop();
    
    //println(GetAnswer());
  }
  
   public byte[] readPacket() {
     return readPacketOrTimeout(0);
   }
  
  private byte[] readPacketOrTimeout(int timeoutMillis) {
    assert(Trigno_Base != null);
    assert(Trigno_Emg != null);
  
    //int EMG_BYTE_BUFFER = 1728 * 8;
    int EMG_BYTE_BUFFER = 128;
  
    int bytesRead = 0;
    long startTime = millis();
   
    byte[] packet = new byte[EMG_BYTE_BUFFER];
    
    if (timeoutMillis != 0 && millis() > startTime+timeoutMillis)
        return null;

    if (Trigno_Emg.available() > 0){
        bytesRead = Trigno_Emg.readBytes(packet);
        //println("Disp :" + Trigno_Emg.available() + " Lidos: " + bytesRead);
    }
    if(bytesRead ==0)
      return null;
    
   
    return Arrays.copyOf(packet,bytesRead);
  }
}
class DelsysTrignoNotDetectedError extends Exception {}
