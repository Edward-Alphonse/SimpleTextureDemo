//
//  DemoViewController.m
//  Hello_Triangle_VBO
//
//  Created by 何知昶 on 2019/2/2.
//  Copyright © 2019 何知昶. All rights reserved.
//

#import "Demo1ViewController.h"
#import <GLKit/GLKit.h>

@interface Demo1ViewController() {
    EAGLContext *_context;
    GLuint _program;
    GLuint vboIds[2];
    GLushort *indices;
    int indiceCount;
    GLuint textureId;
}

@end

@implementation Demo1ViewController

- (void)viewDidLoad {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        NSLog(@"context fail");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = _context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:_context];
    [self setupProgram];
    [self setupVBO];
    [self setupTexture];
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);

}

- (void)setupProgram {
    NSString *vShaderPath = [[NSBundle mainBundle] pathForResource:@"vShader" ofType:@"vsh"];
    NSError *error;
    NSString *vShaderStr = [NSString stringWithContentsOfFile:vShaderPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return ;
    }
    GLuint vShader = [self setupShader:vShaderStr type:GL_VERTEX_SHADER];
    if (vShader == 0) { return ;}
    
    NSString *fShaderPath = [[NSBundle mainBundle] pathForResource:@"fShader" ofType:@"fsh"];
    NSString *fShaderStr = [NSString stringWithContentsOfFile:fShaderPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return ;
    }
    GLuint fShader = [self setupShader:fShaderStr type:GL_FRAGMENT_SHADER];
    if (fShader == 0) { return ;}
    _program = glCreateProgram();
    glAttachShader(_program, vShader);
    glAttachShader(_program, fShader);
    glLinkProgram(_program);
    GLint linked;
    glGetProgramiv(_program, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            GLchar *info = malloc(sizeof(GLchar) * infoLen);
            glGetProgramInfoLog(_program, infoLen, 0, info);
            NSString *log = [NSString stringWithCString:info encoding:NSUTF8StringEncoding];
            NSLog(@"%@", log);
            free(info);
        }
        glDeleteProgram(_program);
    }
}

- (GLuint)setupShader:(NSString *)shaderSrc type: (GLenum) type {
    const char* shaderStrUTF8 = [shaderSrc UTF8String];
    int shaderLen = (int)shaderSrc.length;
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &shaderStrUTF8, &shaderLen);
    glCompileShader(shader);
    GLint compiled;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLen);
            glGetShaderInfoLog(shader, infoLen, 0, infoLog);
            NSString *log = [NSString stringWithCString:infoLog encoding:NSUTF8StringEncoding];
            NSLog(@"%@", log);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}


- (void)setupVBO {
    memset(vboIds, 0, 2);
    
    indiceCount = 6;
    GLushort idxs[6] = { 0, 1, 2, 0, 2, 3 };
    indices = idxs;
    
    GLfloat vertices[4 * 5] =
    { -0.5f,  0.5f, 0.0f,  // Position 0
        0.0f,  0.0f,        // TexCoord 0
        -0.5f, -0.5f, 0.0f,  // Position 1
        0.0f,  1.0f,        // TexCoord 1
        0.5f, -0.5f, 0.0f,  // Position 2
        1.0f,  1.0f,        // TexCoord 2
        0.5f,  0.5f, 0.0f,  // Position 3
        1.0f,  0.0f         // TexCoord 3
    };
    
    glGenBuffers(2, vboIds);
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIds[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(idxs), indices, GL_STATIC_DRAW);
}

- (void)setupTexture {
    GLubyte pixels[4 * 3] =
    {
        255,   0,   0, // Red
        0, 255,   0, // Green
        0,   0, 255, // Blue
        255, 255,   0  // Yellow
    };
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 1, 4, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels);
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    glUseProgram(_program);
    
    int posSize = 3;
    int texCoordSize = 2;
    int ptrOffset = 0;

    GLint posInx = glGetAttribLocation(_program, "a_position");
    GLint textureIdx = glGetAttribLocation(_program, "a_texCoord");
    glEnableVertexAttribArray(posInx);
    glEnableVertexAttribArray(textureIdx);
    glVertexAttribPointer(posInx, posSize, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *(posSize + texCoordSize), ptrOffset);
    ptrOffset += sizeof(GLfloat) * posSize;
    glVertexAttribPointer(textureIdx, texCoordSize, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *(posSize + texCoordSize), ptrOffset);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureId);
    GLint uniform = glGetUniformLocation(_program, "s_texture");
    glUniform1i(uniform, 0);
    
    glDrawElements(GL_TRIANGLES, indiceCount, GL_UNSIGNED_SHORT, 0);
    glDisableVertexAttribArray(posInx);
    glDisableVertexAttribArray(textureIdx);
}

@end
