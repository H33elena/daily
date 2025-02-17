import java.security.*;
import java.util.Base64;

public class asy {
    public static void main(String[] args) throws Exception {
        // Generate key pair
        KeyPairGenerator keyGen = KeyPairGenerator.getInstance("RSA");
        keyGen.initialize(2048);
        KeyPair pair = keyGen.generateKeyPair();
        PrivateKey privateKey = pair.getPrivate();
        PublicKey publicKey = pair.getPublic();

        // Create nickname + nonce string
        String nickname = "elena";
        int nonce = 0;
        String message = nickname + nonce;

        // Find a nonce that results in a hash with 4 leading zeros
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash;
        do {
            nonce++;
            message = nickname + nonce;
            hash = md.digest(message.getBytes());
        } while (!(hash[0] == 0 && hash[1] == 0 && (hash[2] & 0xF0) == 0));

        // Sign the message with the private key
        Signature privateSignature = Signature.getInstance("SHA256withRSA");
        privateSignature.initSign(privateKey);
        privateSignature.update(message.getBytes());
        byte[] signature = privateSignature.sign();

        // Verify the signature with the public key
        Signature publicSignature = Signature.getInstance("SHA256withRSA");
        publicSignature.initVerify(publicKey);
        publicSignature.update(message.getBytes());
        boolean isVerified = publicSignature.verify(signature);

        // Print results
        System.out.println("Message: " + message);
        System.out.println("Signature: " + Base64.getEncoder().encodeToString(signature));
        System.out.println("Verification: " + isVerified);
    }
}
