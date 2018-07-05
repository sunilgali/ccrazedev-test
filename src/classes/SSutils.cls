global class SSutils
{
    
    
    global static string encrypt(string pwd)
    {
       Blob cryptoKey = Crypto.generateAesKey(256);
       Blob data = Blob.valueOf(pwd);
       Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
       String encodedCipherText = EncodingUtil.base64Encode(encryptedData);
       system.debug('encodedCipherText '+ encodedCipherText);
       return encodedCipherText;
    }
    
    
    
    global static string decrypt(Blob enCryptPWD)
    {
       Blob cryptoKey = Crypto.generateAesKey(256);
       Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, enCryptPWD);
       String decryptedDataString = decryptedData.toString();
       
       system.debug('decryptedDataString '+decryptedDataString);
       return decryptedDataString;
    }
   
   
}