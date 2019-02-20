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
    
    indiceCount = 3;
    GLushort idxs[3] = {1, 0, 2};
    indices = idxs;
    
    GLfloat vertices[3 * 7] =
    {
        -0.5f,  0.5f, 0.0f,        // v0
        1.0f,  0.0f, 0.0f, 1.0f,  // c0
        -1.0f, -0.5f, 0.0f,        // v1
        0.0f,  1.0f, 0.0f, 1.0f,  // c1
        0.0f, -0.5f, 0.0f,        // v2
        0.0f,  0.0f, 1.0f, 1.0f,  // c2
        
    };
    
    glGenBuffers(2, vboIds);
    glBindBuffer(GL_ARRAY_BUFFER, vboIds[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vboIds[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(idxs), indices, GL_STATIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    glUseProgram(_program);
    
    int posSize = 3;
    int colorSize = 4;
    int ptrOffset = 0;

    GLint posInx = glGetAttribLocation(_program, "a_position");
    GLint colorIdx = glGetAttribLocation(_program, "a_color");
    glEnableVertexAttribArray(posInx);
    glEnableVertexAttribArray(colorIdx);
    glVertexAttribPointer(posInx, posSize, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *(posSize + colorSize), ptrOffset);
    ptrOffset += sizeof(GLfloat) * posSize;
    glVertexAttribPointer(colorIdx, colorSize, GL_FLOAT, GL_FALSE, sizeof(GLfloat) *(posSize + colorSize), ptrOffset);
    glDrawElements(GL_TRIANGLES, indiceCount, GL_UNSIGNED_SHORT, 0);
    glDisableVertexAttribArray(posInx);
    glDisableVertexAttribArray(colorIdx);
}

@end
