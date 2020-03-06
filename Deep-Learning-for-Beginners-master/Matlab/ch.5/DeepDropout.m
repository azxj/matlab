% DeepDropout 函数基于随机梯度下降策略，使用反向传播算法，通过训练数据集对权重进行更新。
% 与前面不同的是，这里在正向传播过程中采用了 dropout 策略。
%
% W1 为 20x25 矩阵，是输入层与隐藏层 1 之间的权重参数。
% W2 为 20x20 矩阵，是隐藏层 1 与隐藏层 2 之间的权重参数。
% W3 为 20x20 矩阵，是隐藏层 2 与隐藏层 3 之间的权重参数。
% W4 为 5x20 矩阵，是隐藏层 3 与输出层之间的权重参数。
% X 为 5x5x5 张量，包含所有训练样本的特征。
% D 为 5x5 矩阵，包含所有训练样本的标签。
%
% 该函数返回更新后的权重参数 W1、W2、W3 与 W4。
function [W1, W2, W3, W4] = DeepDropout(W1, W2, W3, W4, X, D)
  alpha = 0.01; % 学习率
                % 注意这里的值比起之前的模型要低很多

  N = 5; % 训练数据的数量，亦即张量 X 第一维的大小
  for k = 1:N
    x  = reshape(X(:, :, k), 25, 1); % 一个单独的训练样本的特征向量
                                     % 注意这里进行了 reshape，将矩阵转换为列向量
                                     % 25 维向量
    v1 = W1*x; % 隐藏层 1 的加权和
               % 20x1 矩阵（20 维向量）（[20x25] x [25x1] = [20x1]）
    y1 = Sigmoid(v1); % 隐藏层 1 的完整激活值
                      % 20x1 矩阵（20 维向量）
    y1 = y1 .* Dropout(y1, 0.2); % 隐藏层 1 的真实激活值（经过 dropout 后）
                                 % 20x1 矩阵（20 维向量）

    v2 = W2*y1; % 隐藏层 2 的加权和
                % 20x1 矩阵（20 维向量）（[20x20] x [20x1] = [20x1]）
    y2 = Sigmoid(v2); % 隐藏层 2 的完整激活值
                      % 20x1 矩阵（20 维向量）
    y2 = y2 .* Dropout(y2, 0.2); % 隐藏层 2 的真实激活值（经过 dropout 后）
                                 % 20x1 矩阵（20 维向量）

    v3 = W3*y2; % 隐藏层 3 的加权和
                % 20x1 矩阵（20 维向量）（[20x20] x [20x1] = [20x1]）
    y3 = Sigmoid(v3); % 隐藏层 3 的完整激活值
                      % 20x1 矩阵（20 维向量）
    y3 = y3 .* Dropout(y3, 0.2); % 隐藏层 3 的真实激活值（经过 dropout 后）
                                 % 20x1 矩阵（20 维向量）

    v  = W4*y3; % 输出层的加权和
                % 5x1 矩阵（5 维向量）（[5x20] x [20x1] = [5x1]）
    y  = Softmax(v); % 输出层的激活值
                     % 注意在输出层我们不能使用 dropout
                     % 5x1 矩阵（5 维向量）

    d     = D(k, :)'; % 该样本的标签
                      % 注意这里进行了转置，将行向量转换为列向量
                      % 5 维向量

    e     = d - y; % 输出层的 e
                   % 5x1 矩阵（5 维向量）
    delta = e; % 输出层的 delta
               % 这里由于同时使用了 Softmax 激活函数和 cross entropy 损失函数，所以 delta = e，详见《Matlab Deep Learning》P95
               % 5x1 矩阵（5 维向量）

    e3     = W4'*delta; % 隐藏层 3 的 e
                        % 20x1 矩阵（20 维向量）（[5x20]' x [5x1] = [20x1]）
    delta3 = y3.*(1-y3).*e3; % 隐藏层 3 的 delta，其中 y3.*(1-y3) 是 sigmoid 函数的导数
                             % 20x1 矩阵（20 维向量）

    e2     = W3'*delta3; % 隐藏层 2 的 e
                         % 20x1 矩阵（20 维向量）（[20x20]' x [20x1] = [20x1]）
    delta2 = y2.*(1-y2).*e2; % 隐藏层 2 的 delta，其中 y2.*(1-y2) 是 sigmoid 函数的导数
                             % 20x1 矩阵（20 维向量）

    e1     = W2'*delta2; % 隐藏层 1 的 e
                         % 20x1 矩阵（20 维向量）（[20x20]' x [20x1] = [20x1]）
    delta1 = y1.*(1-y1).*e1; % 隐藏层 1 的 delta，其中 y1.*(1-y1) 是 ReLU 函数的导数
                             % 20x1 矩阵（20 维向量）

    dW4 = alpha*delta*y3'; % 隐藏层 3-输出层权重参数的更新值
                           % 注意这里将 y3 进行了转置，将列向量转换为行向量
                           % 5x20 矩阵（[5x1] x [20x1]' = [5x20]）
    W4  = W4 + dW4; % dW4 和 W4 的形状相同

    dW3 = alpha*delta3*y2'; % 隐藏层 2-隐藏层 3 权重参数的更新值
                            % 注意这里将 y2 进行了转置，将列向量转换为行向量
                            % 20x20 矩阵（[20x1] x [20x1]' = [20x20]）
    W3  = W3 + dW3; % dW3 和 W3 的形状相同

    dW2 = alpha*delta2*y1'; % 隐藏层 1-隐藏层 2 权重参数的更新值
                            % 注意这里将 y1 进行了转置，将列向量转换为行向量
                            % 20x20 矩阵（[20x1] x [20x1]' = [20x20]）
    W2  = W2 + dW2; % dW2 和 W2 的形状相同

    dW1 = alpha*delta1*x'; % 输入层-隐藏层 1 权重参数的更新值
                           % 注意这里将 x 进行了转置，将列向量转换为行向量
                           % 20x25 矩阵（[20x1] x [25x1]' = [20x25]）
    W1  = W1 + dW1; % dW1 和 W1 的形状相同
  end
end
