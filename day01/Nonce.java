import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.nio.charset.StandardCharsets;
import java.util.Date;

public class Nonce {
    public static void main(String[] args) throws NoSuchAlgorithmException {
        findNonceWithLeadingZeros(4);
        findNonceWithLeadingZeros(5);
    }

    private static void findNonceWithLeadingZeros(int leadingZeros) throws NoSuchAlgorithmException {
        String prefix = new String(new char[leadingZeros]).replace('\0', '0');
        int nonce = 0;
        String hash = "";
        long startTime = new Date().getTime();

        while (true) {
            String text = "elena+" + nonce;
            hash = sha256(text);
            if (hash.startsWith(prefix)) {
                break;
            }
            nonce++;
        }

        long endTime = new Date().getTime();
        long timeTaken = endTime - startTime;

        System.out.println("Time taken: " + timeTaken + " ms");
        System.out.println("Nonce: " + nonce);
        System.out.println("Hash: " + hash);
    }

    private static String sha256(String base) throws NoSuchAlgorithmException {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] hash = digest.digest(base.getBytes(StandardCharsets.UTF_8));
        StringBuilder hexString = new StringBuilder();

        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }

        return hexString.toString();
    }
}