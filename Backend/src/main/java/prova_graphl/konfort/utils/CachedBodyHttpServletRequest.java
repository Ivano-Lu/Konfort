package prova_graphl.konfort.utils;

import jakarta.servlet.ReadListener;
import jakarta.servlet.ServletInputStream;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.IOException;


public class CachedBodyHttpServletRequest extends HttpServletRequestWrapper {

    private byte[] chacedBody;

    public CachedBodyHttpServletRequest(HttpServletRequest req) throws IOException {
        super(req);
        InputStream requestInputStream = req.getInputStream();
        this.chacedBody = toByteArray(requestInputStream);
    }

    @Override
    public ServletInputStream getInputStream() throws IOException {
        return new CachedBodyServletInputStream(this.chacedBody);
    }

    private byte[] toByteArray(InputStream input) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int len;
        while ((len = input.read(buffer)) != -1) {
            byteArrayOutputStream.write(buffer, 0 , len);
        }

        return byteArrayOutputStream.toByteArray();
    }

    private static class CachedBodyServletInputStream extends ServletInputStream {

        private final ByteArrayInputStream byteArrayInputStream;

        public CachedBodyServletInputStream(byte[] cachedBody) {
            this.byteArrayInputStream = new ByteArrayInputStream(cachedBody);
        }

        @Override
        public boolean isFinished(){
            return byteArrayInputStream.available() == 0;
        }

        @Override
        public boolean isReady(){
            return true;
        }

        @Override
        public void setReadListener(ReadListener readListener){
            throw new UnsupportedOperationException();
        }

        @Override
        public int read() throws IOException {
            return byteArrayInputStream.read();
        }
    }
}
